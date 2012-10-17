# Copyright (c) 2012 29th Street Publishing, LLC.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of 29th Street Publishing, LLC nor the names of its contributors may
#   be used to endorse or promote products derived from this software without
#   specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

from pymongo import Connection
import bson

import settings as settings
import sys


def get_issue_collection():
    db = get_basic_connection()
    
    return db[settings.MONGO_SETTINGS['issue_collection']]


    
def get_source_collection():
    db = get_basic_connection()
    
    return db[settings.MONGO_SETTINGS['source_collection']]
   

def get_article_collection():
    db = get_basic_connection()
    
    return db[settings.MONGO_SETTINGS['article_collection']] 
    
   

def get_archive_collection():
    db = get_basic_connection()

    return db[settings.MONGO_SETTINGS['archive_collection']] 


def get_collection(name):
    db = get_basic_connection()

    return db[name]
    
    
def get_basic_connection():
    connection = Connection(settings.MONGO_SETTINGS['host'], settings.MONGO_SETTINGS['port'])

    # then, connect to our database
    db = connection[settings.MONGO_SETTINGS['db_name']]

    # and authenticate to use that database
    db.authenticate(settings.MONGO_SETTINGS['username'], settings.MONGO_SETTINGS['password'])

    return db
    
    
def get_unique_obj (id, collection, param='_id'):

    if (not id):
        return 0

    try:
        one = collection.find({param: bson.objectid.ObjectId(id)})
    except Exception, e:
        sys.stderr.write("Something went wrong with id = %s\n" % id)
        return 0
        
        
    if (one and one.count() > 0):
        one = one[0]
    else:
        return 0


    return one


def get_obj (id, collection, param=0):
    one = collection.find({param: ("%s" % id)})

    if (one and one.count() > 0):
        one = one[0]
    else:
        return 0

    return one
    
def get_obj_with_params(collection, param_hash):
    one = collection.find(param_hash)
    if (one and one.count() > 0):
        one = one[0]
    else:
        return 0

    return one
    
    
def remove_obj(id, collection):    
    collection.remove({'_id': bson.objectid.ObjectId(id)})


def mongo_cursor_to_array(cursor, keep_id=False):
        
    array = [ ]

    for c in cursor:
        
        # translate '_id' => 'id'
        if not keep_id:
            if (c and (c.get('_id', 0) != 0)):
                c['id'] = ("%s" % c['_id'])
                del c['_id']
                
        array.append(c)


    return array
