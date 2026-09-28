import zipfile, sys
for f in sys.argv[1:]:
    z = zipfile.ZipFile(f)
    print('==', f.split('/')[-1].split('\\')[-1])
    for i in z.infolist():
        if '.abc' in i.filename or i.filename.startswith('ets/') or '.so' in i.filename:
            print('  %-60s %d' % (i.filename, i.file_size))
