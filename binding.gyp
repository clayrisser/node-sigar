{
    'targets': [
        {
            'target_name': 'sigar',
            'include_dirs': [
                '<!@(node -p "require(\'node-addon-api\').include")',
                'deps/sigar/include',
                'src/include'
            ],
            'sources': [
                'deps/sigar/src/sigar.c',
                'deps/sigar/src/sigar_cache.c',
                'deps/sigar/src/sigar_fileinfo.c',
                'deps/sigar/src/sigar_format.c',
                'deps/sigar/src/sigar_getline.c',
                'deps/sigar/src/sigar_ptql.c',
                'deps/sigar/src/sigar_signal.c',
                'deps/sigar/src/sigar_util.c',
                'src/lib/nodeSigar.cpp',
                'src/lib/proc.cpp'
            ],
            'cflags!': ['-fno-exceptions'],
            'cflags_cc!': ['-fno-exceptions'],
            'xcode_settings': {
                'CLANG_CXX_LIBRARY': 'libc++',
                'GCC_ENABLE_CPP_EXCEPTIONS': 'YES',
                'MACOSX_DEPLOYMENT_TARGET': '10.7',
            },
            'msvs_settings': {
                'VCCLCompilerTool': {'ExceptionHandling': 1},
            },
            'conditions': [
                ['OS=="mac"', {
                    'cflags+': ['-fvisibility=hidden'],
                    'xcode_settings': {
                        'CLANG_CXX_LIBRARY': 'libc++',
                        'GCC_SYMBOLS_PRIVATE_EXTERN': 'YES',
                        'MACOSX_DEPLOYMENT_TARGET': '10.9',
                        'OTHER_LDFLAGS': [
                            '-framework IOKit'
                        ],
                    },
                    'include_dirs': [
                        'deps/sigar/src/os/darwin'
                    ],
                    'sources': [
                        '<!@(ls -1 deps/sigar/src/os/darwin/*.c)'
                    ],
                    'LDFLAGS': [
                        '-framework IOKit'
                    ],
                    "defines": ["DARWIN"]
                }],
                ['OS=="win"', {
                    'include_dirs': [
                        'deps/sigar/src/os/win32'
                    ],
                    'sources': [
                        'deps/sigar/src/os/win32/win32_sigar.c',
                        'deps/sigar/src/os/win32/peb.c',
                        'deps/sigar/src/os/win32/wmi.cpp'
                    ],
                    'libraries': [
                        '-lws2_32',
                        '-lkernel32',
                        '-luser32',
                        '-ladvapi32',
                        '-lnetapi32',
                        '-lshell32',
                        '-lpdh',
                        '-lversion'
                    ],
                    'cflags_cc+': ['-DWIN32']
                }],
                ['OS=="linux"', {
                    'include_dirs': [
                        'deps/sigar/src/os/linux'
                    ],
                    'sources': [
                        '<!@(ls -1 deps/sigar/src/os/linux/*.c)'
                    ]
                }]
            ]
        }
    ]
}
