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
import models.starwatch_log



import datetime, time

# pass in an array of possible values along with the parameter we're searching for.
def summarize_query(term):
    result = { 
        'term': term,
        'values': [ ]
    }
    values = get_starwatch_device_collection().distinct(term)
    
    total_records = get_unique_device_count()
    
    # then, for each of the values, find out how many of the entire collection
    # this value represents.
    
    
    for value in values:
        num_for_value = len(query_device_count_with_term({term: value}))
        result['values'].append({
            'name': value,
            'number': num_for_value,
        })
    
    return result
    


def get_unique_device_versions():
    term = models.starwatch_log.action_identifiers().get('DEVICE_VERSION')
    
    return get_starwatch_device_collection().distinct(term)

def get_unique_device_types():
    device_term = models.starwatch_log.action_identifiers().get('DEVICE_TYPE')
    
    return get_starwatch_device_collection().distinct(device_term)

    
def get_unique_device_count():
    return len(query_device_count_with_term({}))

# this will return an array.
def query_device_count_with_term(term):
    return utility.mongo.mongo_cursor_to_array(get_starwatch_device_collection().find(term))
    
    
def get_starwatch_device_collection():
    return utility.mongo.get_collection(settings.MONGO_SETTINGS['stats_device'])

def get_device_for_id(device_id):
    return utility.mongo.get_obj (device_id, get_starwatch_device_collection(), 'device_id')
    
    
def update_device(device_obj, changes_to_device_obj):
    # if the device id's don't match up, something is grossly wrong
    if (device_obj.get('device_id', False) != changes_to_device_obj.get('device_id', True)):
        return
    
    sys.stderr.write("\t not updating device obj yet.\n")
        
    # device_collection.save(existing_device_record, True)
    
    device_obj = update_keys(device_obj, changes_to_device_obj)
    
    get_starwatch_device_collection().save(device_obj, True)
        
def add_device(device_dictionary):
    # first, make sure this device doesn't exist.
    device = get_device_for_id(device_dictionary['device_id'])    
    
    if (device):
        return update_device(device, device_dictionary)
    
    
    new_device_obj = update_keys(get_device_shell(), device_dictionary)
   
        
    sys.stderr.write("Before adding, new_device_obj = %s\n" % new_device_obj)
            
    get_starwatch_device_collection().insert(new_device_obj)
    
    return get_device_for_id(device_dictionary['device_id'])
    
        
        
    
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
    
    
def get_device_shell():
    return {
        'device_id': '',
        'num_opens': 0,
        'ios': '0.0',
        'device_version': 'Unknown',
        'device': 'Unknown',
        'timezone': '',
        'app_version': 1.0,
    }