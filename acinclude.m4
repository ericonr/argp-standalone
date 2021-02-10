dnl Try to detect the type of the third arg to getsockname() et al
AC_DEFUN([LSH_TYPE_SOCKLEN_T],
[AH_TEMPLATE([socklen_t], [Length type used by getsockopt])
AC_CACHE_CHECK([for socklen_t in sys/socket.h], ac_cv_type_socklen_t,
[AC_EGREP_HEADER(socklen_t, sys/socket.h,
  [ac_cv_type_socklen_t=yes], [ac_cv_type_socklen_t=no])])
if test $ac_cv_type_socklen_t = no; then
        AC_MSG_CHECKING(for AIX)
        AC_EGREP_CPP(yes, [
#ifdef _AIX
 yes
#endif
],[
AC_MSG_RESULT(yes)
AC_DEFINE(socklen_t, size_t)
],[
AC_MSG_RESULT(no)
AC_DEFINE(socklen_t, int)
])
fi
])

dnl LSH_PATH_ADD(path-id, directory)
AC_DEFUN([LSH_PATH_ADD],
[AC_MSG_CHECKING($2)
ac_exists=no
if test -d "$2/." ; then
  ac_real_dir=`cd $2 && pwd`
  if test -n "$ac_real_dir" ; then
    ac_exists=yes
    for old in $1_REAL_DIRS ; do
      ac_found=no
      if test x$ac_real_dir = x$old ; then
        ac_found=yes;
	break;
      fi
    done
    if test $ac_found = yes ; then
      AC_MSG_RESULT(already added)
    else
      AC_MSG_RESULT(added)
      # LDFLAGS="$LDFLAGS -L $2"
      $1_REAL_DIRS="$ac_real_dir [$]$1_REAL_DIRS"
      $1_DIRS="$2 [$]$1_DIRS"
    fi
  fi
fi
if test $ac_exists = no ; then
  AC_MSG_RESULT(not found)
fi
])

dnl LSH_RPATH_ADD(dir)
AC_DEFUN([LSH_RPATH_ADD], [LSH_PATH_ADD(RPATH_CANDIDATE, $1)])

dnl LSH_RPATH_INIT(candidates)
AC_DEFUN([LSH_RPATH_INIT],
[AC_MSG_CHECKING([for -R flag])
RPATHFLAG=''
case `uname -sr` in
  OSF1\ V4.*)
    RPATHFLAG="-rpath "
    ;;
  IRIX\ 6.*)
    RPATHFLAG="-rpath "
    ;;
  IRIX\ 5.*)
    RPATHFLAG="-rpath "
    ;;
  SunOS\ 5.*)
    if test "$TCC" = "yes"; then
      # tcc doesn't know about -R
      RPATHFLAG="-Wl,-R,"
    else
      RPATHFLAG=-R
    fi
    ;;
  Linux\ 2.*)
    RPATHFLAG="-Wl,-rpath,"
    ;;
  *)
    :
    ;;
esac

if test x$RPATHFLAG = x ; then
  AC_MSG_RESULT(none)
else
  AC_MSG_RESULT([using $RPATHFLAG])
fi

RPATH_CANDIDATE_REAL_DIRS=''
RPATH_CANDIDATE_DIRS=''

AC_MSG_RESULT([Searching for libraries])

for d in $1 ; do
  LSH_RPATH_ADD($d)
done
])    

dnl Try to execute a main program, and if it fails, try adding some
dnl -R flag.
dnl LSH_RPATH_FIX
AC_DEFUN([LSH_RPATH_FIX],
[if test $cross_compiling = no -a "x$RPATHFLAG" != x ; then
  ac_success=no
  AC_TRY_RUN([int main(int argc, char **argv) { return 0; }],
    ac_success=yes, ac_success=no, :)
  
  if test $ac_success = no ; then
    AC_MSG_CHECKING([Running simple test program failed. Trying -R flags])
dnl echo RPATH_CANDIDATE_DIRS = $RPATH_CANDIDATE_DIRS
    ac_remaining_dirs=''
    ac_rpath_save_LDFLAGS="$LDFLAGS"
    for d in $RPATH_CANDIDATE_DIRS ; do
      if test $ac_success = yes ; then
  	ac_remaining_dirs="$ac_remaining_dirs $d"
      else
  	LDFLAGS="$RPATHFLAG$d $LDFLAGS"
dnl echo LDFLAGS = $LDFLAGS
  	AC_TRY_RUN([int main(int argc, char **argv) { return 0; }],
  	  [ac_success=yes
  	  ac_rpath_save_LDFLAGS="$LDFLAGS"
  	  AC_MSG_RESULT([adding $RPATHFLAG$d])
  	  ],
  	  [ac_remaining_dirs="$ac_remaining_dirs $d"], :)
  	LDFLAGS="$ac_rpath_save_LDFLAGS"
      fi
    done
    RPATH_CANDIDATE_DIRS=$ac_remaining_dirs
  fi
  if test $ac_success = no ; then
    AC_MSG_RESULT(failed)
  fi
fi
])

dnl Like AC_CHECK_LIB, but uses $KRB_LIBS rather than $LIBS.
dnl LSH_CHECK_KRB_LIB(LIBRARY, FUNCTION, [, ACTION-IF-FOUND [,
dnl                  ACTION-IF-NOT-FOUND [, OTHER-LIBRARIES]]])

AC_DEFUN([LSH_CHECK_KRB_LIB],
[AC_CHECK_LIB([$1], [$2],
  ifelse([$3], ,
      [[ac_tr_lib=HAVE_LIB`echo $1 | sed -e 's/[^a-zA-Z0-9_]/_/g' \
     	    -e 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/'`
        AC_DEFINE_UNQUOTED($ac_tr_lib)
        KRB_LIBS="-l$1 $KRB_LIBS"
      ]], [$3]),
  ifelse([$4], , , [$4
])dnl
, [$5 $KRB_LIBS])
])

dnl LSH_LIB_ARGP(ACTION-IF-OK, ACTION-IF-BAD)
AC_DEFUN([LSH_LIB_ARGP],
[ ac_argp_save_LIBS="$LIBS"
  ac_argp_save_LDFLAGS="$LDFLAGS"
  ac_argp_ok=no
  # First check if we can link with argp.
  AC_SEARCH_LIBS(argp_parse, argp,
  [ LSH_RPATH_FIX
    AC_CACHE_CHECK([for working argp],
      lsh_cv_lib_argp_works,
      [ AC_TRY_RUN(
[#include <argp.h>
#include <stdlib.h>

static const struct argp_option
options[] =
{
  { NULL, 0, NULL, 0, NULL, 0 }
};

struct child_state
{
  int n;
};

static error_t
child_parser(int key, char *arg, struct argp_state *state)
{
  struct child_state *input = (struct child_state *) state->input;
  
  switch(key)
    {
    default:
      return ARGP_ERR_UNKNOWN;
    case ARGP_KEY_END:
      if (!input->n)
	input->n = 1;
      break;
    }
  return 0;
}

const struct argp child_argp =
{
  options,
  child_parser,
  NULL, NULL, NULL, NULL, NULL
};

struct main_state
{
  struct child_state child;
  int m;
};

static error_t
main_parser(int key, char *arg, struct argp_state *state)
{
  struct main_state *input = (struct main_state *) state->input;

  switch(key)
    {
    default:
      return ARGP_ERR_UNKNOWN;
    case ARGP_KEY_INIT:
      state->child_inputs[0] = &input->child;
      break;
    case ARGP_KEY_END:
      if (!input->m)
	input->m = input->child.n;
      
      break;
    }
  return 0;
}

static const struct argp_child
main_children[] =
{
  { &child_argp, 0, "", 0 },
  { NULL, 0, NULL, 0}
};

static const struct argp
main_argp =
{ options, main_parser, 
  NULL,
  NULL,
  main_children,
  NULL, NULL
};

int main(int argc, char **argv)
{
  struct main_state input = { { 0 }, 0 };
  char *v[2] = { "foo", NULL };

  argp_parse(&main_argp, 1, v, 0, NULL, &input);

  if ( (input.m == 1) && (input.child.n == 1) )
    return 0;
  else
    return 1;
}
], lsh_cv_lib_argp_works=yes,
   lsh_cv_lib_argp_works=no,
   lsh_cv_lib_argp_works=no)])

  if test x$lsh_cv_lib_argp_works = xyes ; then
    ac_argp_ok=yes
  else
    # Reset link flags
    LIBS="$ac_argp_save_LIBS"
    LDFLAGS="$ac_argp_save_LDFLAGS"
  fi])

  if test x$ac_argp_ok = xyes ; then
    ifelse([$1],, true, [$1])
  else
    ifelse([$2],, true, [$2])
  fi   
])

dnl LSH_GCC_ATTRIBUTES
dnl Check for gcc's __attribute__ construction

AC_DEFUN([LSH_GCC_ATTRIBUTES],
[AC_CACHE_CHECK(for __attribute__,
	       lsh_cv_c_attribute,
[ AC_TRY_COMPILE([
#include <stdlib.h>
],
[
static void foo(void) __attribute__ ((noreturn));

static void __attribute__ ((noreturn))
foo(void)
{
  exit(1);
}
],
lsh_cv_c_attribute=yes,
lsh_cv_c_attribute=no)])

AH_TEMPLATE([HAVE_GCC_ATTRIBUTE], [Define if the compiler understands __attribute__])
if test "x$lsh_cv_c_attribute" = "xyes"; then
  AC_DEFINE(HAVE_GCC_ATTRIBUTE)
fi

AH_BOTTOM(
[#if __GNUC__ && HAVE_GCC_ATTRIBUTE
# define NORETURN __attribute__ ((__noreturn__))
# define PRINTF_STYLE(f, a) __attribute__ ((__format__ (__printf__, f, a)))
# define UNUSED __attribute__ ((__unused__))
#else
# define NORETURN
# define PRINTF_STYLE(f, a)
# define UNUSED
#endif
])])
