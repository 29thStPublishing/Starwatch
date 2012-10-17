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

####### 
# SWC == Starwatch Captain -- this is our stats parser.
#######

import pymongo
import sys
import re 
import json

from datetime import datetime

import utility.mongo 

import models.starwatch_device
import models.starwatch_log
import models.starwatch_feedback

import settings as settings


def get_active_sessions(limit=20):
    session_collection = utility.mongo.get_collection(settings.MONGO_SETTINGS['stats_session'])
    
    sessions = session_collection.find().sort('start_time', 
                                    pymongo.DESCENDING).limit(limit)
                   
    final_sessions = [ ]
    for s in sessions:
        s['id'] = ("%s" % s['_id'])
        del s['_id']
        
        final_sessions.append(s)
    
    
    return final_sessions


def get_active_device_ids():
    
    device_collection = utility.mongo.get_collection(settings.MONGO_SETTINGS['stats_device'])
    
    return device_collection.find()
    
    
    
# given an array of records, find summarizing info about them
def print_summary_info(records):
    
    
    summary_collection = utility.mongo.get_collection(settings.MONGO_SETTINGS['stats_session'])
    
    
    sys.stderr.write("\n\t~~ Summary Info ~~\n")
    time_usage = calculate_time_in_app(records)
    
    sys.stderr.write("\t Time in the app: %s\n" % time_usage)
    
    device_id = get_device_id(records)
    sys.stderr.write("\t Device id: %s\n" % device_id)
    
    #orientation_ratios = calculate_orientation_ratios (records)
    obj = { } 
    obj = parse_views(records, obj)
    num_rotations = obj['rotations']

    orientation_ratios = obj['orientation']

    sys.stderr.write("\t Orientation Summary:\n")
    
    sys.stderr.write("ORIENTATION_RATIOS OBJ = \n%s\n" % orientation_ratios)
    
    orientation_keys = orientation_strings()
    
    
    for key in obj['orientation'].keys():
        orientation_summary_obj = orientation_ratios[key]
        if orientation_summary_obj.get('percentage') and orientation_summary_obj['percentage'] != '0':
            sys.stderr.write("\t   %s - %s%% (%s seconds)\n" % (orientation_keys[key]['name'], 
                                                            orientation_ratios[key]['percentage'], 
                                                            orientation_ratios[key]['time']))
                                                        
                                                            
    views = obj['views']
    sys.stderr.write("\t View Summary:\n")
    for key in views.keys():
        # [key, permalink] = parse_for_key(key)
        
        sys.stderr.write("\t  %s - %s%% (%s seconds)\n" % (key, 
                                                           views[key]['percentage'],
                                                           views[key]['time']))

    ## here's where we make our summary object.
    summary = {
        'device': device_id,
        'device_type': records[0]['device_type'],
        'usage_time': time_usage.total_seconds(),
        'start_time': records[0]['last_updated'],
        'end_time': records[len(records) - 1]['last_updated'],
        'orientation': orientation_ratios,
        'rotations': obj['rotations'],
        'views': obj['views'],
        'actions': obj.get('actions', [])
    }
        
    
    return summary_collection.insert(summary)
    
    #return 0
    
    




def parse_views (records, obj):
    
    orientations = orientation_strings()
    
    # build the hash array.
    keys = orientations.keys()
    
    start_time = records[0]['last_updated']
    end_time = records[len(records) - 1]['last_updated']
    
    current_orientation = {
        'name': '',
        'time': start_time
    }
    
    orientation_history = [ ] 
    
    view_history = calculate_view_history(records)
    
    
    
    for record in records:
            
        if (record['action'] == 'rotate'):
            sys.stderr.write("VIEW action = %s - %s - %s (%s)\n" % (record['view'], record['action'], record['metadata'], record['last_updated']))
            
            
            if (record['metadata'] != current_orientation['name']):            
                orientation_history.append({
                    'name': record['metadata'],
                    'time': record['last_updated']
                })
                
                # update our obj.
                current_orientation['name'] = record['metadata']
                current_orientation['time'] = record['last_updated']
        
    
   
    
    # at the end, loop over the orientation history.
    #sys.stderr.write("Orientation History:\n")
    #sys.stderr.write("Time\tOrientation\n")
    
    # set up our orientation objects.
    summary = { }
    for k in keys:
        summary[k] = { }
        
    start = datetime.strptime(start_time, time_format())
    end = datetime.strptime(end_time, time_format())
    
    delta = end - start
    total_seconds = delta.total_seconds()
    
    t = start
    
    i = 0 
    
    # first, calculate the orientation times.
    if (len(orientation_history) == 1):
        tilt = orientation_history[0]
        for k in keys:
            if (tilt['name'] == orientations[k]['name']):
                this_time = datetime.strptime(tilt['time'], time_format())
                summary[k]['time'] = delta.total_seconds()
                summary[k]['percentage'] = '100'
                
                last_time = k
            else:
                summary[k]['time'] = 0
                summary[k]['percentage'] = '0'
                
                
    else:   
        last_record = ''
        current_orientation = ''

        # for tilt in orientation_history:
        i = len(orientation_history) - 1
        
        t = end
        if (i == 0):
            for k in keys:            
                summary[k]['time'] = 0
                summary[k]['percentage'] = '0'
        else:
            
            while (i >= 0):

                tilt = orientation_history[i]
            
                for k in keys:            
                    orientation_record = summary[k]
                    if not orientation_record.has_key('time'):
                        summary[k]['time'] = 0
                        summary[k]['percentage'] = '0'
            
                    if (tilt['name'] == orientations[k]['name']):                    
                        this_time = datetime.strptime(tilt['time'], time_format())
                        delta = t - this_time
                        t = this_time
                        # sys.stderr.write("Orientation = %s, delta = %s\n" % (tilt['name'], delta))                   
                        summary[k]['time'] = summary[k]['time'] + delta.total_seconds()
                        summary[k]['percentage'] = ("%.2f" % ((summary[k]['time'] / total_seconds) * 100))
        
        
                i = i - 1
        

    sys.stderr.write("View History:\n")
    sys.stderr.write("Start ->\n")
    obj['actions'] = []
    for v in view_history:
        sys.stderr.write("\t %s (%s) at %s ->\n" % (v['name'], v['global_id'], v['time']))
        sys.stderr.write("all of v = %s\n" % v)
        obj['actions'].append({
            'view': v['name'],
            'global_id': v['global_id'],
            'timestamp': v['time']
        })
    sys.stderr.write("End\n")
    
    views = { 
        'breakout': [ ] 
    } 
    
    
    # then, calculate the Views breakout
    # -----------------------------------
    if (len(view_history) == 1):
        v = view_history[0]  
       
        breakout_obj = { } 
       
        
        this_time = datetime.strptime(v['time'], time_format())
        breakout_obj['time'] = delta.total_seconds()
        breakout_obj['percentage'] = '100'
        
        # [k, permalink] = parse_for_key(v['name'])
        k = v['name']
        permalink = v['global_id']

        breakout_obj = { 
                k: {
                    'time': delta.total_seconds(),
                    'percentage': '100',
                    'permalink': permalink
                }
        }
        views['breakout'] = breakout_obj
        
        add_view(v['name'], v['global_id'])
        

    # more than one view.
    else:        
        last_record = ''
        current_view = ''

        i = len(view_history) - 1

        t = end

        breakout_obj = { } 

        while (i >= 0):

            v = view_history[i]
            
            # our names are loaded. :(
            [k, permalink] = parse_for_key(v['name'])
    

            if not breakout_obj.has_key(k):
                breakout_obj[k] = { 
                    'time': 0,
                    'percentage': '0'
                }
                
                add_view(k, v['global_id'])
                
                

            this_time = datetime.strptime(v['time'], time_format())
            delta = t - this_time
            t = this_time

            breakout_obj[k]['time'] = breakout_obj[k]['time'] + delta.total_seconds()
            if (breakout_obj[k]['time'] == 0):
                breakout_obj[k]['percentage'] = ("%.2f" % 0.0)
            else:
                breakout_obj[k]['percentage'] = ("%.2f" % ((breakout_obj[k]['time'] / total_seconds) * 100))
            breakout_obj[k]['permalink'] = permalink


            i = i - 1    

        # and add the breakout_obj to the views obj
        views['breakout'] = breakout_obj
    
    # these are the viewing stats
    obj['views'] = views['breakout']
    
    # finally, include the number of tilts.
    obj['rotations'] = len(orientation_history) - 1
    
    obj['orientation'] = summary
    
    
    return obj
    
    
    
# it's the difference between the first and last record's last_updated value.    
def calculate_time_in_app(records):
    
    
    start_time = datetime.strptime(records[0]['last_updated'], time_format())
    end_time   = datetime.strptime(records[len(records) - 1]['last_updated'], time_format())
    
    return end_time - start_time
    
# here's where we'd push this to the device collection.    
def get_device_id(records):
    device_id = records[0]['device']
    
    device_collection = utility.mongo.get_collection(settings.MONGO_SETTINGS['stats_device'])
    
    last_access = records[len(records) - 1]['last_updated']
    
    obj = {
        'device': device_id,
        'device_type': records[len(records) - 1]['device_type'],
        'last_access': last_access
    }
    
    existing_device_record = utility.mongo.get_obj (device_id, device_collection, 'device')
    
    if (not existing_device_record):
        
        sys.stderr.write("No device with device=%s; creating\n" % device_id)
        
        device_collection.insert(obj)    
    else:
        
        sys.stderr.write("Record with device=%s exists; updating\n" % device_id)
        
        existing_device_record['last_access'] = last_access
        device_collection.save(existing_device_record, True)
    
    return device_id


# -- the open source version of this method is very likely to change
# -- NP
def parse_actions(starting_action, limit=200):    
    count = limit
        
    i = 0
    
    log_collection = utility.mongo.get_collection(settings.MONGO_SETTINGS['stats_log'])
    
    
    
    sys.stderr.write("\n\n*** Parsing for starting action = '%s'... *** \n" % starting_action)
    

    logs = log_collection.find({'action': starting_action, 
                                'view': 'app_delegate',
                                'session_id': { '$exists' : False }
                                }).sort('last_updated', pymongo.ASCENDING).skip(i).limit(limit)
    
    for log_record_start in logs:
        
        # only work with these records if we don't already have a session for it.
        # when we're ready to work with real data...
        if ((not log_record_start.has_key('session_id')) or 
            (log_record_start['session_id'] == 0) or
            (log_record_start['session_id'] == "0")):
        #if 1:

            # fetch all the records up until the entered_background -- that's what 
            # defines one app usage.
            usage_ending_session = log_collection.find({'device': log_record_start['device'], 
                                                        'action': 'entered_background',
                                                        'last_updated': {'$gte': log_record_start['last_updated']}}).sort('last_updated', pymongo.ASCENDING).limit(1)


            # these are all the closed-app actions.
            if usage_ending_session.count() == 0:
                sys.stderr.write("No complete session data; leaving these records alone.\n")     
            else:    
                log_record_end = usage_ending_session[0]

            
                # then, get all the actions in-between.
                session_actions_cursor = log_collection.find({'device': log_record_start['device'],
                                                       'last_updated': {
                                                        '$gte': log_record_start['last_updated'],
                                                        '$lte': log_record_end['last_updated']
                                                       }}).sort('last_updated', pymongo.ASCENDING)


                sys.stderr.write("\n\n\t ~~ Session Data ~~\n")
                sys.stderr.write("Device-ID\tTime\tView\tAction\tMetadata\tID\n")

                session_actions = [ ]
                for session_action in session_actions_cursor:
                    sys.stderr.write("%s\t%s\t%s\t%s\t%s\t%s\n" % (session_action['device'],
                        session_action['last_updated'], 
                        session_action['view'],
                        session_action['action'],
                        session_action['metadata'],
                        session_action['_id']))
                    session_actions.append(session_action)

                summary_id = print_summary_info(session_actions)
            
                # then, add the summary_id record to these actions.
                for s in session_actions:
                    s['session_id'] = ("%s" % summary_id)
                    # del s['_id']
                
                    log_collection.save(s, True)
                
                


        i = i + 1
        

# given any set of records, provide:
# -- number of app usages
# -- orientation averages
# -- average app usage time
def calculate_summary (summary_records):
    summary = {
        'num_sessions': len(summary_records),
        'orientation': { 
        },
        'views': {
        },
        'device_types': {
        }
    }
    
    total_usage_time = 0
    total_rotations = 0 
    found_views = get_views()
    
    
    num_summary_records = 0
    
    for record in summary_records:
        #if (!((settings.SKIP_SIMULATOR == 1) && )):
        #if (settings.SKIP_SIMULATOR == 0 or (not is_device_simulator(record['device_type']))):
        if (1):
            num_summary_records = num_summary_records + 1
            
            total_usage_time = total_usage_time + record['usage_time']
        
            for key in record['orientation']:  
                orientation_obj = summary['orientation']
                if not orientation_obj.has_key(key):
                    summary['orientation'][key] = 0

                orientation_record = record['orientation'][key]
                if not orientation_record.has_key('percentage'):
                    record['orientation'][key]['percentage'] = 0
                
                summary['orientation'][key] = summary['orientation'][key] + float(record['orientation'][key]['percentage'])
    
            key = record['device_type']

            device_obj = summary['device_types']
            if not device_obj.has_key(key):
                summary['device_types'][key] = 0
            summary['device_types'][key] = summary['device_types'][key] + float(1.0)
    
            # also count the number of tilts.
            total_rotations = total_rotations + record['rotations']
        
            # you have to get the listing of views here.
            for v in found_views:
                key = v['name']
                permalink = v['permalink']
            
                # sys.stderr.write("new key = %s, permalink = %s\n" % (key, permalink))
            
                view_obj = summary['views']
            
                if (not view_obj or not view_obj.has_key(key)):
                    summary['views'][key] = {
                        'value': 0,
                        'permalink': ''
                    }
                 
            
                if (record['views'].has_key(key)):
                    summary['views'][key]['value'] = summary['views'][key]['value'] + float(record['views'][key]['percentage'])
                    summary['views'][key]['permalink'] = permalink

            
            
            

    # then, for each device_type, calculate the percentage of each.
    if (num_summary_records == 0):
        num_summary_records = 1  # avoid div by 0 errors
    
    for device_key in summary['device_types']:
        sum = summary['device_types'][device_key]
        p = float(sum) / float(num_summary_records) * 100
        summary['device_types'][device_key] = ("%.2f" % p)
        
    # average time of each session    
    if total_usage_time == 0:
        summary['average_usage_time'] = 0
    else:
        summary['average_usage_time'] = ("%s seconds" % (total_usage_time / num_summary_records))
    
    summary['total_usage_time'] = total_usage_time

    if total_rotations == 0:
        summary['average_number_rotations'] = 0
    else:
        summary['average_number_rotations'] = ("%.2s" % (float(total_rotations) / num_summary_records))
    
    # average percentage of each orientation.
    for keys in summary['orientation']:
        summary['orientation'][keys] = ("%s%%" % (summary['orientation'][keys] / num_summary_records))

    # average percentage for each view.
    for view in found_views:
        view = view['name']
        summary['views'][view] = ("%s%%" % (summary['views'][view]['value'] / num_summary_records))

    return summary
    
    
    
    
    
def get_views ():
    view_collection = utility.mongo.get_collection(settings.MONGO_SETTINGS['stats_view'])
    
    views = view_collection.find()
    final_views = [ ]

    for v in views:
        v['id'] = ("%s" % v['_id'])
        del v['_id']
        
        final_views.append(v)
    
    return final_views
    
def add_view(view_name, global_id):
    
    if (global_id == ""):
        global_id = "Utility"
        
    view_collection = utility.mongo.get_collection(settings.MONGO_SETTINGS['stats_view'])
    
    
    obj = {
        'name': view_name,
        'global_id': global_id
    }    

    #existing_obj = utility.mongo.get_obj (view_name, view_collection, 'name')
    
    existing_obj = utility.mongo.mongo_cursor_to_array(view_collection.find({
                                    'global_id': global_id, 
                                    'name': view_name,
                                    }))
    
    
    if existing_obj:
        sys.stderr.write("The view %s already exists.\n" % view_name)
        return
    
    else:
        view_collection.insert({
            'name': view_name,
            'global_id': global_id
        })
    
def parse_for_key(key):
    
    # sys.stderr.write("\n[parse_for_key] key = %s\n" % key)
    p = re.compile('^(Article-[\d]+)-(http://[^\s]+)$')
    m = p.match(key)
    
    if (m != None):        
        return [m.group(1), m.group(2)]
    
    
    p = re.compile('^(Photo-[\d]+)-(http://[^\s]+)$')
    m = p.match(key)
    if (m != None):        
        return [m.group(1), m.group(2)]
        
    return [key, ""]
    
    
def is_device_simulator(device_string):
    if "simulator" in device_string.lower():
        return 1
    
    
    return 0


def time_format():
    return '%Y%m%d %H:%M:%S'
    
    
def orientation_strings ():
    return {
       'portrait-upside-down': {
            'name': 'Portrait - Upside Down',
            'is_portrait': 1
        },
        'landscape-left': {
            'name': "Landscape - Left",
            'is_portrait': 0
        },
        'landscape-right': {
            'name': "Landscape - Right",
            'is_portrait': 0
        },
        'portrait-standard': {
            'name': "Portrait - Standard",
            'is_portrait': 1
        }
    }
    
# for an array of records in this session, find the views by collating the things that 
# start with 'view_begin' and end in 'view_complete'
def calculate_view_history(records):
    
    # first, get the identifying information.
    device_id = records[0]['device']
    
    open_time = records[0]['last_updated']
    close_time = records[len(records) - 1]['last_updated']
    
    
    log_collection = utility.mongo.get_collection(settings.MONGO_SETTINGS['stats_log'])
    
    view_begin_actions = utility.mongo.mongo_cursor_to_array(log_collection.find({'action': 'view_begin', 
                                'session_id': { '$exists' : False },
                                'last_updated': {
                                    '$gte': open_time,
                                    '$lte': close_time
                                },
                                'device': device_id
                                }).sort('last_updated', pymongo.ASCENDING))
                                
    #sys.stderr.write("[calculate_view_history] view_begin_actions = %s\n" % view_begin_actions)
    
    seen_views = [ ]
    for view_begin in view_begin_actions:
        sys.stderr.write("View Begin: %s (%s)\n" % (view_begin['view'], view_begin['last_updated']))
        
        seen_views.append({
            'name': view_begin['view'],
            'global_id': view_begin['global_id'],
            'time': view_begin['last_updated']
        })
    
    
    return seen_views                          
    
    #'name': record['view'],
    #'time': record['last_updated']
    
    

    
def parse_for_info(limit):
       
    info_logs = models.starwatch_log.get_info_logs(limit) 
                         
    for info_log in info_logs:
        sys.stderr.write("Last updated: %s\n" % info_log.get('last_updated'))
        
        device_id = info_log.get('device', 'UNKNOWN')
        metadata = json.loads(info_log.get('metadata', {}))
        sys.stderr.write("\t metadata: %s\n" % metadata)
        
        known_device = models.starwatch_device.get_device_for_id(device_id)
        if (known_device):
            sys.stderr.write("KNOWN DEVICE; we should update it.\n")
            models.starwatch_device.update_device(known_device, metadata)
            
        else:
            # add the id.
            metadata['device_id'] = device_id
            models.starwatch_device.add_device(metadata)
            
        info_log['metadata'] = metadata
        models.starwatch_log.set_info_flag(info_log)
        
    
    
    
    
def summarize_info_results():
    total_devices = models.starwatch_device.get_unique_device_count()
    
    sys.stderr.write("\n==== AFTER PARSING INFO LOGS ====\n")
    
    sys.stderr.write(" %d total apps installed\n" % total_devices)

    
    types    = models.starwatch_device.summarize_query(models.starwatch_log.action_identifiers().get('DEVICE_TYPE'))
    sys.stderr.write(" Device Type breakdown:\n")
    formatted_summary_table(types, total_devices)
   
    versions = models.starwatch_device.summarize_query(models.starwatch_log.action_identifiers().get('DEVICE_VERSION'))
    sys.stderr.write("\n Version Type breakdown:\n")
    formatted_summary_table(versions, total_devices)
    
    ios_version = models.starwatch_device.summarize_query(models.starwatch_log.action_identifiers().get('IOS_VERSION'))
    sys.stderr.write("\n iOS Version Type breakdown:\n")
    formatted_summary_table(ios_version, total_devices)
    
    timezones = models.starwatch_device.summarize_query(models.starwatch_log.action_identifiers().get('TIMEZONE'))
    sys.stderr.write("\n Timezone breakdown:\n")
    formatted_summary_table(timezones, total_devices)
        
    app_versions = models.starwatch_device.summarize_query(models.starwatch_log.action_identifiers().get('APP_VERSION'))
    sys.stderr.write("\n App version breakdown:\n")
    formatted_summary_table(app_versions, total_devices)
    
    return
    



def formatted_summary_table(dict, total_devices):
    sys.stderr.write("\t%15s \t # \t %% \n" % "Value")
    sys.stderr.write("\t--------------------------------------\n")

    for type in dict.get('values', [ ]):
        sys.stderr.write("\t%15s \t %d \t %.0f %%\n" % (type['name'], type['number'], ((type['number'] / float(total_devices)) * 100)))
    
    
# this clears the 'info_tracked' flag for all log records.
def clear_info_results():
    limit = models.starwatch_log.num_parsed_info_logs()
    
    info_logs = models.starwatch_log.get_info_logs(limit) 
    
    for info_log in info_logs:
        models.starwatch_log.clear_info_flag(info_log)
        
    
def clear_feedback():
    limit = models.starwatch_log.num_parsed_feedback_logs()
    logs = models.starwatch_log.get_feedback_logs(limit, False) 
    
    for log in logs:
        sys.stderr.write("Feedback log: %s\n" % log)
        models.starwatch_log.clear_feedback_flag(log)
    
    
def parse_for_feedback(limit):
    feedback_logs = models.starwatch_log.get_feedback_logs(limit) 
    for log in feedback_logs:
        sys.stderr.write("Last updated: %s\n" % log.get('last_updated'))
        sys.stderr.write("Metadata: %s\n" % log.get('metadata', ''))
        
        # add this feedback record.
        
        models.starwatch_feedback.add_feedback({
            'article_id': log.get('global_id', '0'),
            'device_id': models.starwatch_device.get_device_for_id(log.get('device', '')).get('device_id'),
            'timestamp': log.get('last_updated', ''),
            'message': log.get('metadata', ''),
        })
        
        # mark this record as done.
        models.starwatch_log.set_feedback_flag(log)
        
    
def list_feedback():
    sys.stderr.write("\t%20s \t %15s \t %15s\n" % ("Device ID", "Article ID", "Message"))
    sys.stderr.write("\t--------------------------------------\n")

    feedback_obj = models.starwatch_feedback.get_recent_feedback(50)
    for feedback in feedback_obj:
        device = feedback['device_id']
        sys.stderr.write("\t%20s \t %15s \t %15s\n" % (feedback['device_id'], feedback['article_id'], feedback['message']))
    
    
        
    