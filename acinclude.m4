dnl ARGP_CHECK_VAR(VAR, INCLUDES)
AC_DEFUN(ARGP_CHECK_VAR,
[ AC_CACHE_CHECK(
    [for $1],
    lsh_cv_var_$1,
    AC_TRY_LINK([$2], [void *p = (void *) &$1;],
		[lsh_cv_var_$1=yes],
		[lsh_cv_var_$1=no]))
  if eval "test \"`echo '$lsh_cv_var_'$1`\" = yes"; then
    AC_DEFINE_UNQUOTED(HAVE_`echo $1 | tr 'abcdefghijklmnopqrstuvwxyz' 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'`)
  fi
])
