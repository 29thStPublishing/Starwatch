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

import sys
import pymongo
import html
import json



import settings as settings

import utility.mongo 


import datetime, time

def get_collection():
    return utility.mongo.get_collection(settings.MONGO_SETTINGS['stats_feedback'])


def get_recent_feedback(limit=50):
    return utility.mongo.mongo_cursor_to_array(get_collection().find().sort('last_updated', pymongo.ASCENDING).limit(limit))

def get_feedback_for_id(feedback_id):
    return utility.mongo.get_unique_obj (feedback_id, get_collection())
    
def add_feedback(feedback_dictionary):
   new_feedback_obj = update_keys(get_feedback_shell(), feedback_dictionary)
   
   sys.stderr.write("Before adding, new_feedback_obj = %s\n" % new_feedback_obj)
   
   new_feedback_obj_id = get_collection().insert(new_feedback_obj)
   
   return get_feedback_for_id(new_feedback_obj_id)
                                   
def get_feedback_shell():
   return {
       'device_id': '',
       'article_id': '',
       'timestamp': '',
       'message': '',
   }
   
  
def update_keys(original_obj, values):
   for key in original_obj.keys():
       if (key != '_id'):
           if (isinstance(original_obj[key], str)):
               original_obj[key] = values.get(key, '')
           elif (isinstance(original_obj[key], int)):
               original_obj[key] = int(values.get(key, 0))
           elif (isinstance(original_obj[key], float)):
               original_obj[key] = float(values.get(key, 0.0))
   
   return original_obj
   