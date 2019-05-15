#!/usr/bin/env python

# This script is released under Creative Commons Zero (CC0).
#
# The author hereby waives all copyright and related or
# neighboring rights together with all associated claims
# and causes of action with respect to this work to the
# extent possible under the law.
#
# See: https://creativecommons.org/publicdomain/zero/1.0/legalcode

import sys

# check for compatible Python version
if sys.version_info.major < 3:
	print('\nERROR: this script requires Python 3, using {}'.format(sys.version.split()[0]))
	sys.exit(1)

import errno, os, subprocess
from subprocess import CalledProcessError, DEVNULL
from PIL import Image


# FIXME: use "PIL" or "wand" module (ImageMagick) for converting images


WIN32 = sys.platform == 'win32'
exe = os.path.basename(sys.argv[0])
if WIN32:
	dir_temp = os.getenv('TEMP')
else:
	dir_temp = '/tmp'


def showUsage():
	usage = '\nUsage:\n\t{} <source> <target>'.format(exe)
	usage += '\n\nArguments:\n\n\tsource:  Input image.\n\ttarget:  Output image'
	print(usage)


def getCommand(cmd_name):
	cmd = None

	try:
		if WIN32:
			cmd = subprocess.check_output(('where', cmd_name,), stderr=DEVNULL).decode('utf-8').strip(' \t\r\n')
			# user first executable found
			cmd = cmd.split('\r\n')[0]
		else:
			cmd = subprocess.check_output(('which', cmd_name,), stderr=DEVNULL).decode('utf-8').strip(' \t\r\n')
	except CalledProcessError:
		pass

	return cmd


args = tuple(sys.argv[1:])

if len(args) != 2:
	print('\nERROR: requires exactly two arguments')
	showUsage()
	sys.exit(1)

source = args[0]
target = args[1]

if os.path.isdir(source):
	print('\nERROR: source is a directory: {}'.format(source))
	sys.exit(errno.EISDIR)

if os.path.isdir(target):
	print('\nERROR: target is a directory: {}'.format(target))
	sys.exit(errno.EISDIR)

if not os.path.isfile(source):
	print('\nERROR: could not find source file: {}'.format(source))
	sys.exit(errno.ENOENT)


sys.stdout.write('\nChecking for "convert" executable ...')

# FIXME: Windows has a "convert" executable that is not related to ImageMagick
cmd_convert = getCommand('convert')
if not cmd_convert:
	print('\nERROR: could not find "convert" command\n       Please install ImageMagick: https://imagemagick.org/')
	sys.exit(errno.ENOENT)

print(' {}'.format(cmd_convert))

sys.stdout.write('\nChecking image dimensions ...')

# PIL
img = Image.open(source)

print(' {}'.format(img.size))

# cropping width & height
crop_wh = '{}x{}'.format(img.size[0], int(img.size[1] / 4))

sys.stdout.write('\nCreating temporary pieces ...')

f_basename = '.'.join(os.path.basename(source).split('.')[:-1])
f_suffix = source.split('.')[-1]

proc = subprocess.Popen((cmd_convert, source, '-define', 'png:format=png32', '-crop', crop_wh, os.path.join(dir_temp, '{}-TMP.{}'.format(f_basename, f_suffix)),))
out, err = proc.communicate()

temp_pieces = []
for I in (2, 3, 1, 0,):
	p = os.path.join(dir_temp, '{}-TMP-{}.{}'.format(f_basename, I, f_suffix))

	if not os.path.isfile(p):
		print('\n\nERROR: failed to created temporary images in "{}"'.format(dir_temp))
		sys.exit(errno.ENOENT)

	temp_pieces.append(p)

sys.stdout.write(' done!\n\nCreating new image from temporary pieces ...')

join_args = tuple([cmd_convert,] + temp_pieces + ['-define', 'png:format=png32', '-append', target,])

proc = subprocess.Popen(join_args)
out, err = proc.communicate()

print(' done!')
