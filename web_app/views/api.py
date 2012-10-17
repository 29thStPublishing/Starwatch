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

import json
import simplejson
import logging
import tornado.auth
import tornado.escape
import tornado.ioloop
import tornado.options
import tornado.web
import os.path
import uuid
import tornado.httpserver
import sys

import utility.SWC
import utility.mongo

import settings

import models.starwatch_device, models.starwatch_feedback, models.starwatch_log

class DefaultApiHandler(tornado.web.RequestHandler):

    def get_query_param(self, key, default=0):

        value_array = self.get_arguments(key, default)

        if (value_array and len(value_array) > 0):
            return value_array[0]

        return ''

    def render(self, json_obj={}, is_json=1, **kwargs):         
        # self.content_type='application/json'     

        if (is_json == 1):
            self.write(simplejson.dumps(json_obj))
            self.content_type='application/json'     

            return

        # otherwise, it's javascript.
        c = self.get_query_param('callback')

        #return super(DefaultHandler, self).render_string(template_name, **kwargs)
        self.write("%s(%s)" % (c, simplejson.dumps(json_obj)))
        self.content_type='application/javascript'     

        return


class ListDevices(DefaultApiHandler):
    def get(self, is_json):
        
        self.render({
            'types': models.starwatch_device.summarize_query(models.starwatch_log.action_identifiers().get('DEVICE_TYPE')),
            'versions': models.starwatch_device.summarize_query(models.starwatch_log.action_identifiers().get('DEVICE_VERSION')),
           
            'ios_version': models.starwatch_device.summarize_query(models.starwatch_log.action_identifiers().get('IOS_VERSION')),
            
           
            'timezones': models.starwatch_device.summarize_query(models.starwatch_log.action_identifiers().get('TIMEZONE')),  
            'num_devices': models.starwatch_device.get_unique_device_count()
                   
        }, (is_json == 'json'))

def app_view(request, view_id):
    view_collection = get_collection('view')
    view = get_unique_obj(view_id, view_collection)

    if (not view): 
        sys.stderr.write("Didn't find device %s.\n" % device_id)
        view = { 
        }

        return  HttpResponse(simplejson.dumps(view),
            mimetype='application/json')

    view['id'] = ("%s" %  view['_id'])

    del view['_id']     

    session_collection = get_collection('session')
    # compare this to the average.
    sessions = list(session_collection.find({}))
    view['summary'] = calculate_summary(sessions)



    return  HttpResponse(simplejson.dumps(view),
        mimetype='application/json')

def device(request, device_id):

    device_collection = get_collection('device')    
    device = get_obj(device_id, device_collection, 'device')

    if (not device): 
        sys.stderr.write("Didn't find device %s.\n" % device_id)
        device = { 
            'sessions': [ ] 
        }

        return  HttpResponse(simplejson.dumps(device),
            mimetype='application/json')


    # clear the _id field to be serializable.
    del device['_id']        

    # also, get the session records for this device.
    session_collection = get_collection('session')
    device_sessions = session_collection.find({'device': device_id}).sort('start_time', pymongo.DESCENDING)

    sessions = [ ] 
    for device_session in device_sessions:
        device_session['id'] = ("%s" % device_session['_id'])
        del device_session['_id']

        sessions.append(device_session)

    device['summary'] = calculate_summary(sessions)
    device['sessions'] = sessions

    return  HttpResponse(simplejson.dumps(device),
        mimetype='application/json')


# this guy is in progress. 
def session_by_date(request, date_string):
    session_collection = get_collection('session')

    return ""


def views_all(request):
    v_collection = get_collection('view')

    views = v_collection.find()
    final_views = [ ]
    for v in views:
        v['id'] = ("%s" % v['_id'])
        del v['_id']
        final_views.append(v)

    return  HttpResponse(simplejson.dumps(final_views),
         mimetype='application/json')  

def sessions_all(request):
    session_collection = get_collection('session')

    sessions = session_collection.find().sort('start_time', pymongo.DESCENDING);

    summaries = { 
        'sessions': [ ]
    }

    for session in sessions:
        session_id = session['_id']
        del session['_id']

        session['id'] = ("%s" % session_id)
        summaries['sessions'].append(session)

    summaries['summary'] = calculate_summary(summaries['sessions'])


    return  HttpResponse(simplejson.dumps(summaries),
         mimetype='application/json')   


def session(request, session_id):
    session_collection = get_collection('session')

    session = get_unique_obj(session_id, session_collection)    

    if (not session): 
        session = { }

        return  HttpResponse(simplejson.dumps(session),
            mimetype='application/json')

    session_id = ("%s" % session['_id'])
    del session['_id']

    log_collection = get_collection('log')
    logs = log_collection.find({'session_id': session_id})
    final_logs = [ ]
    for log in logs:
        log['id'] = ("%s" % log['_id'])
        del log['_id']

        final_logs.append(log)


    # attempting to force a sort-order
    session['logs'] = final_logs

    # compare this to the average.
    sessions = list(session_collection.find({}))
    session['summary'] = calculate_summary([session])


    return  HttpResponse(simplejson.dumps(session),
        mimetype='application/json')
    
    

def API_VERSION():
    return "1.0"