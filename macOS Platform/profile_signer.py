#!/usr/bin/python

import argparse
import subprocess
import os
import sys
import tempfile
from Foundation import NSPropertyListSerialization, NSData, NSPropertyListXMLFormat_v1_0, NSPropertyListMutableContainers

#Copied from FoundationPlist
class FoundationPlistException(Exception):
    """Basic exception for plist errors"""
    pass

class NSPropertyListSerializationException(FoundationPlistException):
    """Read/parse error for plists"""
    pass

class NSPropertyListWriteException(FoundationPlistException):
    """Write error for plists"""
    pass

def readPlist(filepath):
    """
    Read a .plist file from filepath.  Return the unpacked root object
    (which is usually a dictionary).
    """
    plistData = NSData.dataWithContentsOfFile_(filepath)
    dataObject, dummy_plistFormat, error = (
        NSPropertyListSerialization.
        propertyListFromData_mutabilityOption_format_errorDescription_(
            plistData, NSPropertyListMutableContainers, None, None))
    if dataObject is None:
        if error:
            error = error.encode('ascii', 'ignore')
        else:
            error = "Unknown error"
        errmsg = "%s in file %s" % (error, filepath)
        raise NSPropertyListSerializationException(errmsg)
    else:
        return dataObject


def readPlistFromString(data):
    '''Read a plist data from a string. Return the root object.'''
    try:
        plistData = buffer(data)
    except TypeError, err:
        raise NSPropertyListSerializationException(err)
    dataObject, dummy_plistFormat, error = (
        NSPropertyListSerialization.
        propertyListFromData_mutabilityOption_format_errorDescription_(
            plistData, NSPropertyListMutableContainers, None, None))
    if dataObject is None:
        if error:
            error = error.encode('ascii', 'ignore')
        else:
            error = "Unknown error"
        raise NSPropertyListSerializationException(error)
    else:
        return dataObject


def writePlist(dataObject, filepath):
    '''
    Write 'rootObject' as a plist to filepath.
    '''
    plistData, error = (
        NSPropertyListSerialization.
        dataFromPropertyList_format_errorDescription_(
            dataObject, NSPropertyListXMLFormat_v1_0, None))
    if plistData is None:
        if error:
            error = error.encode('ascii', 'ignore')
        else:
            error = "Unknown error"
        raise NSPropertyListSerializationException(error)
    else:
        if plistData.writeToFile_atomically_(filepath, True):
            return
        else:
            raise NSPropertyListWriteException(
                "Failed to write plist data to %s" % filepath)


def writePlistToString(rootObject):
    '''Return 'rootObject' as a plist-formatted string.'''
    plistData, error = (
        NSPropertyListSerialization.
        dataFromPropertyList_format_errorDescription_(
            rootObject, NSPropertyListXMLFormat_v1_0, None))
    if plistData is None:
        if error:
            error = error.encode('ascii', 'ignore')
        else:
            error = "Unknown error"
        raise NSPropertyListSerializationException(error)
    else:
        return str(plistData)




def main():
    parser = argparse.ArgumentParser(description='Sign or encrypt mobileconfig profiles, using either a cert + key file, or a keychain certificate.')
    parser.add_argument('sign', choices=('sign', 'encrypt', 'both'), help='Choose to sign, encrypt, or do both on a profile.')
    key_group = parser.add_argument_group('Keychain arguments', description='Use these if you wish to sign with a Keychain certificate.')
    key_group.add_argument('-k', '--keychain', help='Name of keychain to search for cert. Defaults to login.keychain',
                        default='login.keychain')
    key_group.add_argument('-n', '--name', help='Common name of certificate to use from keychain.', required=True)
    parser.add_argument('infile', help='Path to input .mobileconfig file')
    parser.add_argument('outfile', help='Path to output .mobileconfig file. Defaults to outputting into the same directory.')
    args = parser.parse_args()
    
    if args.sign == 'encrypt' or args.sign == 'both':
        if args.sign == 'both':
            outputFile = args.outfile + '_unsigned'
        else:
            outputFile = args.outfile
        # encrypt the profile only, do not sign
        # Encrypting a profile:
        # 1. Extract payload content into its own file
        # 2. Serial that file as its own plist
        # 3. CMS-envelope that content (using openssl for now)
        # 4. Remove "PayloadContent" key and replace with "EncryptedPayloadContent" key
        # 5. Replace the PayloadContent <array> with <data> tags instead

        # Step 1: Extract payload content into its own file
        myProfile = readPlist(args.infile)
        payloadContent = myProfile['PayloadContent']

        # Step 2: Serialize that file into its own plist
        (pContentFile, pContentPath) = tempfile.mkstemp()
        #print "pContentPath: %s" % pContentPath
        writePlist(payloadContent, pContentPath)
        
        # Step 3: Use openssl to encrypt that content
        # First, we need to extract the certificate we want to use from the keychain
        security_cmd = ['/usr/bin/security', 'find-certificate', '-c', args.name, '-p' ]
        if args.keychain:
            security_cmd += [args.keychain]
        proc = subprocess.Popen(security_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (sout, serr) = proc.communicate()
        if serr:
            print >> sys.stderr, "Error: %s" % serr
            sys.exit(1)
        # Now write the certificate to a temp file
        (certfile, certpath) = tempfile.mkstemp('.der')
        #print "Certpath: %s" % certpath
        try:
            with open(certpath, 'wb') as f:
                f.write(sout)
        except IOError:
            print >> sys.stderr, "Could not write to file!"
            sys.exit(1)      
        # Now use openssl to encrypt the payload content using that certificate
        (encPContentfile, encPContentPath) = tempfile.mkstemp('.plist')
        #print "encPContentPath: %s" % encPContentPath
        enc_cmd = ['/usr/bin/openssl', 'smime', '-encrypt', '-aes256', '-outform', 'der', 
                '-in', pContentPath, '-out', encPContentPath]
        enc_cmd += [certpath]
        proc = subprocess.Popen(enc_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (encout, encerr) = proc.communicate()
        if encerr:
            print >> sys.stderr, "Error: %s" % encerr
            sys.exit(1)
        # openssl smime -encrypt produces no output if successful
        
        # Step 4: Add the new encrypted payload content back into the plist
        with open(encPContentPath, 'rb') as f:
            binaryEncPayload = f.read()
        del myProfile['PayloadContent']
        wrapped_data = NSData.dataWithBytes_length_(binaryEncPayload, len(binaryEncPayload))
        myProfile['EncryptedPayloadContent'] = wrapped_data

        # Step 5: Replace the plist with the new content
        plistData, error = NSPropertyListSerialization.dataFromPropertyList_format_errorDescription_(myProfile, NSPropertyListXMLFormat_v1_0, None)
        plistData.writeToFile_atomically_(outputFile, True)

        # Now clean up after ourselves
        os.remove(pContentPath)
        os.remove(certpath)
        os.remove(encPContentPath)
    
    if args.sign == 'sign' or args.sign == 'both':
        # Keychain check:
        if not args.name:
            print >> sys.stderr, 'Error: A certificate common name is required to sign profiles with the Keychain.'
            sys.exit(22)
        if args.sign == 'both':
            # If we already encrypted it, then the correct file is already in outputFile
            inputFile = outputFile
        else:
            inputFile = args.infile
        cmd = ['/usr/bin/security', 'cms', '-S', '-N', args.name, '-i', inputFile, '-o', args.outfile ]
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (sout, serr) = proc.communicate()
        if serr:
            print >> sys.stderr, 'Error: %s' % serr
            sys.exit(1)
        if args.sign == 'both':
            os.remove(outputFile)
        
if __name__ == '__main__':
    main()