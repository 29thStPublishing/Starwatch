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

def get_starwatch_log_collection():
    return utility.mongo.get_collection(settings.MONGO_SETTINGS['stats_log'])
    
def clear_info_flag(log_obj):
    
    if (log_obj.get(info_tracked_flag(), False)):
        del log_obj[info_tracked_flag()]
    
        get_starwatch_log_collection().save(log_obj, True)
    
def set_info_flag(log_obj):
    log_obj[info_tracked_flag()] = True
    
    get_starwatch_log_collection().save(log_obj, True)
    
def info_tracked_flag():
    return 'info_tracked'
    
def clear_feedback_flag(log_obj):

    if (log_obj.get(feedback_tracked_flag(), False)):
        del log_obj[feedback_tracked_flag()]

    get_starwatch_log_collection().save(log_obj, True)

def set_feedback_flag(log_obj):
    log_obj[feedback_tracked_flag()] = True

    get_starwatch_log_collection().save(log_obj, True)    
    
def feedback_tracked_flag():
    return 'feedback_tracked'
    
def get_info_logs(limit):
        
    action_mappings = action_identifiers()
    info_action = action_mappings['INFO']
    
    return utility.mongo.mongo_cursor_to_array(
        get_starwatch_log_collection().find({'action': info_action, 
                                info_tracked_flag(): { '$exists' : False }
                                }).sort('last_updated', pymongo.ASCENDING).limit(limit),
                                True)
    
def get_feedback_logs(limit, unparsed_Only=True):
    action_mappings = action_identifiers()
    feedback_action = action_mappings['FEEDBACK']
    
    if (unparsed_Only):
        return utility.mongo.mongo_cursor_to_array(
        get_starwatch_log_collection().find({'action': feedback_action, 
                                       feedback_tracked_flag(): { '$exists' : False }
                                       }).sort('last_updated', pymongo.ASCENDING).limit(limit),
                                       True) 
    return utility.mongo.mongo_cursor_to_array(
    get_starwatch_log_collection().find({'action': feedback_action, 
                                  }).sort('last_updated', pymongo.ASCENDING).limit(limit),
                                  True)
    
    
def num_parsed_feedback_logs():
    return get_starwatch_log_collection().find({'action':  action_identifiers().get('FEEDBACK'), 
                            feedback_tracked_flag(): { '$exists' : True }
                            }).count()
                            
def num_parsed_info_logs():
    return get_starwatch_log_collection().find({'action':  action_identifiers().get('INFO'), 
                            info_tracked_flag(): { '$exists' : True }
                            }).count()
# right side is what's used in the iOS app.
def action_identifiers():
    return {
        'INFO': 'info',
        'DEVICE_TYPE': 'device',
        'DEVICE_VERSION': 'device_version',
        'TIMEZONE': 'timezone',
        'IOS_VERSION': 'ios',
        'APP_VERSION': 'app_version',
        'FEEDBACK': 'feedback'
    }