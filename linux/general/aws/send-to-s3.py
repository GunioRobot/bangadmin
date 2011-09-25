#!/usr/bin/env python

# Usage
#send_to_s3.py "<local_file_path>" "<s3_path>"

import sys
import os

local_file_path = sys.argv[1]
s3_path = sys.argv[2]

from boto.s3.connection import S3Connection
from boto.s3.key import Key


# Initiate a S3 connection using key and secret
conn = S3Connection('account key here', 'account secert here')

# The bucket name
pb = conn.get_bucket('j_backups')


# Make an S3 key using the bucket
k = Key(pb)
file_name_to_use_in_s3 = "%s/%s"%(s3_path, os.path.basename(local_file_path))
# Set the name of the file to use in S3
# S3 doesn't have  the concept of directories
# Use / in the file name to mimic the directory path
k.name = file_name_to_use_in_s3
k.set_metadata('Cache-Control', 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0')
# Send the file to S3
k.set_contents_from_filename(local_file_path)
print "Sent %s to %s"%(local_file_path, file_name_to_use_in_s3)
sys.exit(0)
