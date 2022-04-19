project('argp-standalone', 'c')

argp_source = files([
	'argp-ba.c',
	'argp-eexst.c',
	'argp-fmtstream.c',
	'argp-help.c',
	'argp-parse.c',
	'argp-pv.c',
	'argp-pvh.c',
	#'argp-test.c'
])

install_headers('argp.h')

conf_data = configuration_data()

cc = meson.get_compiler('c')

conf_data.set10('HAVE_CONFIG_H', true)
conf_data.set10('HAVE_ALLOCA_H', cc.check_header('alloca.h'))

conf_data.set('HAVE_LIMITS_H', cc.check_header('limits.h'))
conf_data.set('HAVE_MALLOC_H', cc.check_header('malloc.h'))
conf_data.set('HAVE_UNISTD_H', cc.check_header('unistd.h'))
conf_data.set('HAVE_LIBINTL_H', cc.check_header('libintl.h'))

# conf_data.set10('_LIBC', true)

conf_data.set10('HAVE_DECL_FLOCKFILE', cc.has_function('flockfile'))
conf_data.set10('HAVE_DECL_FPUTS_UNLOCKED', cc.has_function('fputs_unlocked', prefix : '#include <stdio.h>'))
conf_data.set10('HAVE_DECL_FPUTC_UNLOCKED', cc.has_function('fputc_unlocked', prefix : '#include <stdio.h>'))
conf_data.set10('HAVE_DECL_FWRITE_UNLOCKED', cc.has_function('fwrite_unlocked', prefix : '#include <stdio.h>'))
conf_data.set10('HAVE_DECL_PUTC_UNLOCKED', cc.has_function('putc_unlocked', prefix : '#include <stdio.h>'))

conf_data.set10('HAVE_MEMPCPY', cc.has_function('mempcpy', prefix : '#include <string.h>'))
conf_data.set10('HAVE_ASPRINTF', cc.has_function('asprintf', prefix: '#include <stdio.h>'))
conf_data.set10('HAVE_STRCHRNUL', cc.has_function('strchrnul', prefix: '#include <string.h>'))
conf_data.set10('HAVE_STRNDUP', cc.has_function('strndup', prefix: '#include <string.h>'))
conf_data.set10('HAVE_STRCASECMP', cc.has_function('strcasecmp', prefix: '#include <string.h>'))

conf_data.set10('HAVE_DECL_PROGRAM_INVOCATION_NAME',
			    cc.has_function('program_invocation_name', prefix : '#include <errno.h>'))
conf_data.set10('HAVE_DECL_PROGRAM_INVOCATION_SHORT_NAME',
				cc.has_function('program_invocation_short_name', prefix : '#include <errno.h>'))

deps = []
if cc.check_header('libintl.h')
	deps += dependency('intl')
endif

configure_file(input : 'meson_config.h.in',
               output : 'config.h',
               configuration : conf_data)

add_global_arguments('-DHAVE_CONFIG_H=1', language : 'c')

if conf_data.get('HAVE_STRCHRNUL') == 0
	argp_source += files(['strchrnul.c'])
endif
if conf_data.get('HAVE_STRNDUP') == 0
	argp_source += files(['strndup.c'])
endif
if conf_data.get('HAVE_STRCASECMP') == 0
	argp_source += files(['strcasecmp.c'])
endif
if conf_data.get('HAVE_MEMPCPY') == 0
	argp_source += files(['mempcpy.c'])
endif

argp_library = static_library('argp',
	argp_source,
	include_directories : '.',
	dependencies : deps,
	install : true
)

e = executable('ex1', 'testsuite/ex1.c', link_with : [argp_library])
test('ex1', e)
e3 = executable('ex3', 'testsuite/ex3.c', link_with : [argp_library])
# test('ex3', e)
e4 = executable('ex4', 'testsuite/ex4.c', link_with : [argp_library])
# test('ex4', e)
