{
  'targets': [
    {
      'target_name': 'sigar',
      'include_dirs': [
        '<!@(node -p "require(\'node-addon-api\').include")',
        'deps/sigar/include',
        'deps/sigar/src/os/linux',
        'src/include'
      ],
      'sources': [
        '<!@(ls -1 deps/sigar/src/*.c)',
        '<!@(ls -1 deps/sigar/src/os/linux/*.c)',
        '<!@(ls -1 src/lib/*.cpp)'
      ],
      'cflags!': [ '-fno-exceptions' ],
      'cflags_cc!': [ '-fno-exceptions' ],
      'xcode_settings': {
        'CLANG_CXX_LIBRARY': 'libc++',
        'GCC_ENABLE_CPP_EXCEPTIONS': 'YES',
        'MACOSX_DEPLOYMENT_TARGET': '10.7',
      },
      'msvs_settings': {
        'VCCLCompilerTool': { 'ExceptionHandling': 1 },
      },
      'conditions': [
        ['OS=="mac"', {
          'cflags+': ['-fvisibility=hidden'],
          'xcode_settings': {
            'GCC_SYMBOLS_PRIVATE_EXTERN': 'YES'
          }
        }],
        ['OS=="win"', {

        }],
      ]
    }
  ]
}
