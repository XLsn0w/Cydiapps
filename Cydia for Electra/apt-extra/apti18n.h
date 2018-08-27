#define setlocale(a, b)
#define textdomain(a)
#define bindtextdomain(a, b)
#define _(x) x
#define P_(msg,plural,n) (n == 1 ? msg : plural)
#define N_(x) x
#define dgettext(d, m) m
