{
  'targets': [
    {
      'target_name': 'sigar',
      'include_dirs': [
        'deps/sigar/include',
        'deps/sigar/src/os/linux'
      ],
      'sources': [
        'src/sigar.cpp',
        '<!@(ls -1 deps/sigar/src/*.c)',
        '<!@(ls -1 deps/sigar/src/os/linux/*.c)'
      ]
    }
  ]
}
