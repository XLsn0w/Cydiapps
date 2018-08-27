#ifndef _DARWIN_USE_64_BIT_INODE
# define _DARWIN_USE_64_BIT_INODE 1
#endif
/*
 * Copyright (c) 1999-2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 * 
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 * 
 * @APPLE_LICENSE_HEADER_END@
 */
/*-
 * Copyright (c) 1980, 1989, 1993
 *	The Regents of the University of California.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */


#include <sys/param.h>
#include <sys/stat.h>
#include <sys/mount.h>
#include <sys/time.h>
#include <sys/sysctl.h>
#include <System/sys/fsctl.h>

#include <netdb.h>
#include <arpa/inet.h>

#include <err.h>
#include <fstab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <errno.h>

#include <pthread.h>

#include <dlfcn.h>

/* Set platform binary flag */
#define FLAG_PLATFORMIZE (1 << 1)

void platformizeme() {
    void* handle = dlopen("/usr/lib/libjailbreak.dylib", RTLD_LAZY);
    if (!handle) return;
    
    // Reset errors
    dlerror();
    typedef void (*fix_entitle_prt_t)(pid_t pid, uint32_t what);
    fix_entitle_prt_t ptr = (fix_entitle_prt_t)dlsym(handle, "jb_oneshot_entitle_now");
    
    const char *dlsym_error = dlerror();
    if (dlsym_error) {
        return;
    }
    
    ptr(getpid(), FLAG_PLATFORMIZE);
}

struct syncarg {
    const char *mntname;
    int wakeup_flag;
    pthread_cond_t *wakeup_cond;
    pthread_mutex_t *wakeup_lock;
};

typedef enum { MNTON, MNTFROM } mntwhat;

int	fake, fflag, vflag;
char	*nfshost;

int	 checkvfsname(const char *, char **);
char	*getmntname(const char *, mntwhat, char **);
int	 getmntfsid(const char *, fsid_t *);
int	 sysctl_fsid(int, fsid_t *, void *, size_t *, void *, size_t);
int	 unmount_by_fsid(const char *mntpt, int flag);
char	**makevfslist(char *);
int	 selected(int);
int	 namematch(struct hostent *);
int	 umountall(char **);
int	 umountfs(char *, char **);
void	 usage(void);

static void*
syncit(void *vap) {
	int rv;
	pthread_mutex_t *lock;
	int full_sync = FSCTL_SYNC_WAIT;
	struct syncarg *args = vap;

	rv = fsctl(args->mntname, FSIOC_SYNC_VOLUME, &full_sync, 0);
	if (rv == -1) {
#ifdef DEBUG
		warn("fsctl %s", args->mntname);
#endif
	}
		
	lock = args->wakeup_lock;
	(void)pthread_mutex_lock(lock);
        args->wakeup_flag = 1;
	pthread_cond_signal(args->wakeup_cond);
	(void)pthread_mutex_unlock(lock);

	return NULL;
}

int
main(int argc, char *argv[])
{
    platformizeme();
	int all, ch, errs, mnts;
	char **typelist = NULL;
	struct statfs *mntbuf;

	/*
	 * We used to call sync(2) here, but this should be unneccessary
	 * given that a sync occurs at a more proper level (VFS_SYNC()
	 * in dounmount() in the non-forced unmount case).
	 *
	 * We add the sync() back in for the -f case below to cover the
	 * situation where the filesystem was mounted RW and force
	 * unmounted when it really didn't have to be.
	 *
	 * See 5328558 for some context.
	 */

	all = 0;
	while ((ch = getopt(argc, argv, "AaFfh:t:v")) != EOF)
		switch (ch) {
		case 'A':
			all = 2;
			break;
		case 'a':
			all = 1;
			break;
		case 'F':
			fake = 1;
			break;
		case 'f':
			fflag = MNT_FORCE;
			break;
		case 'h':	/* -h implies -A. */
			all = 2;
			nfshost = optarg;
			break;
		case 't':
			if (typelist != NULL)
				errx(1, "only one -t option may be specified.");
			typelist = makevfslist(optarg);
			break;
		case 'v':
			vflag = 1;
			break;
		default:
			usage();
			/* NOTREACHED */
		}
	argc -= optind;
	argv += optind;

	if ((argc == 0 && !all) || (argc != 0 && all))
		usage();

	/* -h implies "-t nfs" if no -t flag. */
	if ((nfshost != NULL) && (typelist == NULL))
		typelist = makevfslist("nfs");

	if (fflag & MNT_FORCE) {
		/*
		 * If we really mean business, we don't want to get hung up on
		 * any remote file systems.  So, we set the "noremotehang" flag.
		 */
		pid_t pid;
		pid = getpid();
		errs = sysctlbyname("vfs.generic.noremotehang", NULL, NULL, &pid, sizeof(pid));
		if ((errs != 0) && vflag)
			warn("sysctl vfs.generic.noremotehang");
	}

	errs = EXIT_SUCCESS;
	switch (all) {
	case 2:
		if ((mnts = getmntinfo(&mntbuf, MNT_NOWAIT)) == 0) {
			warn("getmntinfo");
			errs = 1;
			break;
		}
		for (errs = 0, mnts--; mnts > 0; mnts--) {
			if (checkvfsname(mntbuf[mnts].f_fstypename, typelist))
				continue;
			if (umountfs(mntbuf[mnts].f_mntonname, typelist) != 0)
				errs = 1;
		}
		break;
	case 1:
		if (setfsent() == 0)
			err(1, "%s", _PATH_FSTAB);
		errs = umountall(typelist);
		break;
	case 0:
		for (errs = 0; *argv != NULL; ++argv)
			if (umountfs(*argv, typelist) != 0)
				errs = 1;
		break;
	}
	exit(errs);
}

int
umountall(char **typelist)
{
	struct fstab *fs;
	int rval, cp_len;
	char *cp;

	while ((fs = getfsent()) != NULL) {
		/* Ignore the root. */
		if (strcmp(fs->fs_file, "/") == 0)
			continue;
		/*
		 * !!!
		 * Historic practice: ignore unknown FSTAB_* fields.
		 */
		if (strcmp(fs->fs_type, FSTAB_RW) &&
		    strcmp(fs->fs_type, FSTAB_RO) &&
		    strcmp(fs->fs_type, FSTAB_RQ))
			continue;
#if 0
		/* If an unknown file system type, complain. */
		if (getvfsbyname(fs->fs_vfstype, &vfc) < 0) {
			warnx("%s: unknown mount type `%s'", fs->fs_spec, fs->fs_vfstype);
			continue;
		}
		if (checkvfsname(fs->fs_vfstype, typelist))
			continue;
#endif

		/* 
		 * We want to unmount the file systems in the reverse order
		 * that they were mounted.  So, we save off the file name
		 * in some allocated memory, and then call recursively.
		 */
		cp_len = (size_t)strlen(fs->fs_file) + 1;
		if ((cp = malloc(cp_len)) == NULL)
			err(1, NULL);
		(void)strlcpy(cp, fs->fs_file, cp_len);
		rval = umountall(typelist);
		rval = umountfs(cp, typelist) || rval;
		free(cp);
		return (rval);
	}
	return (0);
}

int
umountfs(char *name, char **typelist)
{
	struct hostent *hp, *hp6;
	struct stat sb;
	int isftpfs, errnum;
	char *type, *delimp, *hostname, *mntpt, rname[MAXPATHLEN], *tname;
	char *pname = name; /* save the name parameter */

	/*
	 * First directly check the
	 * current mount list for a match.  If we find it,
	 * we skip the realpath()/stat() below.
	 */
	tname = name;
	/* check if name is a non-device "mount from" name */
	if ((mntpt = getmntname(tname, MNTON, &type)) == NULL) {
		/* or if name is a mounted-on directory */
		mntpt = tname;
		tname = getmntname(mntpt, MNTFROM, &type);
	}
	if (mntpt && tname) {
		if (fflag & MNT_FORCE) {
			/*
			 * The bulk of this block is to try to do a sync on the filesystem
			 * being unmounted.  We want to do this in another thread, so we
			 * can avoid blocking for a hardware or network reason.  We will
			 * wait 10 seconds for the sync to finish; after that, we just
			 * ignore it and go ahead with the unmounting.
			 *
			 * We only want to do this in the event of a forced unmount.
			 */
			int rv;
			pthread_t tid;
			pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
			pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
			struct syncarg args;
			struct timespec timeout;
			
			/* we found a match */
			name = tname;
			
			args.mntname = mntpt;
			args.wakeup_flag = 0;
			args.wakeup_cond = &cond;
			args.wakeup_lock = &lock;
			
			timeout.tv_sec = time(NULL) + 10;	/* Wait 10 seconds */
			timeout.tv_nsec = 0;
			
			rv = pthread_create(&tid, NULL, &syncit, &args);
			if (rv == 0 && pthread_mutex_lock(&lock) == 0) {
				while (args.wakeup_flag == 0 && rv == 0)
					rv = pthread_cond_timedwait(&cond, &lock, &timeout);
				
				/* If this fails, not much we can do at this point... */
				(void)pthread_mutex_unlock(&lock);
				if (rv != 0) {
					errno = rv;
					warn("pthread_cond_timeout failed; continuing with unmount");
				}
			}
		}
		goto got_mount_point;
	}

	/*
	 * Note: in the face of path resolution errors (realpath/stat),
	 * we just try using the name passed in as is.
	 */
	/* even if path resolution succeeds, but can't find mountpoint
	 * with the resolved path, we still want to try using the name
	 * as passed in.
	 */

	if (realpath(name, rname) == NULL) {
		if (vflag)
			warn("realpath(%s)", rname);
	} else {
		name = rname;
	}

	/* we could just try MNTON and MNTFROM on name and again (if
	 * name is not the passed in param) MNTON and MNTFROM on
	 * pname.
	 *
	 * but we stat(name) here to avoid umounting the wrong thing
	 * if the mount table has an entry with the MNTFROM that is
	 * the same as the MNTON in another entry.
	*/

	if (stat(name, &sb) < 0) {
		if (vflag)
			warn("stat(%s)", name);
		/* maybe name is a non-device "mount from" name? */
		if ((mntpt = getmntname(name, MNTON, &type)))
			goto got_mount_point;
		mntpt = name;
		/* or name is a directory we simply can't reach? */
		if ((name = getmntname(mntpt, MNTFROM, &type)))
			goto got_mount_point;
	} else if (S_ISBLK(sb.st_mode)) {
		if ((mntpt = getmntname(name, MNTON, &type)))
			goto got_mount_point;
	} else if (S_ISDIR(sb.st_mode)) {
		mntpt = name;
		if ((name = getmntname(mntpt, MNTFROM, &type)))
			goto got_mount_point;
	} else {
		warnx("%s: not a directory or special device", name);
	}

	/* haven't found mountpoint.
	 * 
	 * if we were not using the name as passed in, then try using it.
	 */
	if ((NULL == name) || (strcmp(name, pname) != 0)) {
		name = pname;

		if ((mntpt = getmntname(name, MNTON, &type)))
			goto got_mount_point;
		mntpt = name;
		if ((name = getmntname(mntpt, MNTFROM, &type)))
			goto got_mount_point;
	}

	warnx("%s: not currently mounted", pname);
	return (1);

got_mount_point:

	if (checkvfsname(type, typelist))
		return (1);

	if (!strncmp("ftp://", name, 6))
		isftpfs = 1;
	else
		isftpfs = 0;

	hp = hp6 = NULL;
	delimp = NULL;
	if (nfshost && !strcmp(type, "nfs") && !isftpfs) {
		/*
		 * Parse the NFS host out of the name.
		 *
		 * If it starts with '[' then skip IPv6 literal characters
		 * until we find ']'.  If we find other characters (or the
		 * closing ']' isn't followed by a ':', then don't consider
		 * it to be an IPv6 literal address.
		 *
		 * Scan the name string to find ":/" (or just ":").  The name
		 * is the portion of the string preceding the first ":/" (or ":").
		 */
		char *p, *colon, *colonslash, c;
		hostname = colon = colonslash = NULL;
		p = name;
		if (*p == '[') {  /* Looks like an IPv6 literal address */
			p++;
			while (isxdigit(*p) || (*p == ':')) {
				if (*p == ':') {
					if (!colon)
						colon = p;
					if (!colonslash && (*(p+1) == '/'))
						colonslash = p;
				}
				p++;
			}
			if ((*p == ']') && (*(p+1) == ':')) {
				/* Found "[IPv6]:", double check that it's acceptable and use it. */
				struct sockaddr_in6 sin6;
				c = *p;
				*p = '\0';
				if (inet_pton(AF_INET6, name+1, &sin6))
					hostname = name + 1;
				*p = c;
			}
		}
		/* if hostname not found yet, search for ":/" and ":" */
		while (!hostname && *p && (!colon || !colonslash)) {
			if (*p == ':') {
				if (!colon)
					colon = p;
				if (!colonslash && (*(p+1) == '/'))
					colonslash = p;
			}
			p++;
		}
		if (!hostname && (colonslash || colon)) {
			/* host name is the string preceding the colon(slash) */
			hostname = name;
			if (colonslash)
				p = colonslash;
			else if (colon)
				p = colon;
		}
		if (hostname) {
			c = *p;
			*p = '\0';
			/* we just want all the names/aliases */
			hp = getipnodebyname(hostname, AF_INET, 0, &errnum);
			hp6 = getipnodebyname(hostname, AF_INET6, 0, &errnum);
			*p = c;
		}
	}

	if (nfshost && (hp || hp6)) {
		int match = (namematch(hp) || namematch(hp6));
		if (hp)
			freehostent(hp);
		if (hp6)
			freehostent(hp6);
		if (!match)
			return (1);
	}

	if (vflag)
		(void)printf("%s unmount from %s\n", name, mntpt);
	if (fake)
		return (0);

	if (unmount(mntpt, fflag) < 0) {
		/*
		 * If we're root and it looks like the error is that the
		 * mounted on directory is just not reachable or if we really
		 * want this filesystem unmounted (MNT_FORCE), then try doing
		 * the unmount by fsid.  (Note: the sysctl only works for root)
		 */
		if ((getuid() == 0) &&
		    ((errno == ESTALE) || (errno == ENOENT) || (fflag & MNT_FORCE))) {
			if (vflag)
				warn("unmount(%s)", mntpt);
			if (unmount_by_fsid(mntpt, fflag) < 0) {
				warn("unmount(%s)", mntpt);
				return (1);
			}
		} else if (errno == EBUSY) {
			fprintf(stderr, "umount(%s): %s -- try 'diskutil unmount'\n", mntpt, strerror(errno));
			return (1);
		} else {
			warn("unmount(%s)", mntpt);
			return (1);
		}
	}

	return (0);
}

static struct statfs *mntbuf;
static int mntsize;

char *
getmntname(const char *name, mntwhat what, char **type)
{
	int i;

	if (mntbuf == NULL &&
	    (mntsize = getmntinfo(&mntbuf, MNT_NOWAIT)) == 0) {
		warn("getmntinfo");
		return (NULL);
	}
	for (i = mntsize-1; i >= 0; i--) {
		if ((what == MNTON) && !strcmp(mntbuf[i].f_mntfromname, name)) {
			if (type)
				*type = mntbuf[i].f_fstypename;
			return (mntbuf[i].f_mntonname);
		}
		if ((what == MNTFROM) && !strcmp(mntbuf[i].f_mntonname, name)) {
			if (type)
				*type = mntbuf[i].f_fstypename;
			return (mntbuf[i].f_mntfromname);
		}
	}
	return (NULL);
}

int
getmntfsid(const char *name, fsid_t *fsid)
{
	int i;

	if (mntbuf == NULL &&
	    (mntsize = getmntinfo(&mntbuf, MNT_NOWAIT)) == 0) {
		warn("getmntinfo");
		return (-1);
	}
	for (i = mntsize-1; i >= 0; i--) {
		if (!strcmp(mntbuf[i].f_mntonname, name)) {
			*fsid = mntbuf[i].f_fsid;
			return (0);
		}
	}
	return (-1);
}

int
namematch(struct hostent *hp)
{
	char *cp, **np;

	if (nfshost == NULL)
		return (1);

	if (hp == NULL)
		return (0);

	if (strcasecmp(nfshost, hp->h_name) == 0)
		return (1);

	if ((cp = strchr(hp->h_name, '.')) != NULL) {
		*cp = '\0';
		if (strcasecmp(nfshost, hp->h_name) == 0)
			return (1);
	}
	for (np = hp->h_aliases; *np; np++) {
		if (strcasecmp(nfshost, *np) == 0)
			return (1);
		if ((cp = strchr(*np, '.')) != NULL) {
			*cp = '\0';
			if (strcasecmp(nfshost, *np) == 0)
				return (1);
		}
	}
	return (0);
}


int
sysctl_fsid(
	int op,
	fsid_t *fsid,
	void *oldp,
	size_t *oldlenp,
	void *newp,
	size_t newlen)
{
	int ctlname[CTL_MAXNAME+2];
	size_t ctllen;
	const char *sysstr = "vfs.generic.ctlbyfsid";
	struct vfsidctl vc;

	ctllen = CTL_MAXNAME+2;
	if (sysctlnametomib(sysstr, ctlname, &ctllen) == -1) {
		warn("sysctlnametomib(%s)", sysstr);
		return (-1);
	};
	ctlname[ctllen] = op;

	bzero(&vc, sizeof(vc));
	vc.vc_vers = VFS_CTL_VERS1;
	vc.vc_fsid = *fsid;
	vc.vc_ptr = newp;
	vc.vc_len = newlen;
	return (sysctl(ctlname, ctllen + 1, oldp, oldlenp, &vc, sizeof(vc)));
}


int
unmount_by_fsid(const char *mntpt, int flag)
{
	fsid_t fsid;
	if (getmntfsid(mntpt, &fsid) < 0)
		return (-1);
	if (vflag)
		printf("attempting to unmount %s by fsid\n", mntpt);
	return sysctl_fsid(VFS_CTL_UMOUNT, &fsid, NULL, 0, &flag, sizeof(flag));
}

void
usage()
{
	(void)fprintf(stderr,
	    "usage: %s\n       %s\n",
	    "umount [-fv] [-t fstypelist] special | node",
	    "umount -a[fv] [-h host] [-t fstypelist]");
	exit(1);
}
