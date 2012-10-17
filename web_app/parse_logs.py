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

import utility.mongo
import utility.SWC


# Our goal is to find complete sessions -- start_app to entered_background.
# -- we also care about the became_active action
# logs = log_collection.find({'action': 'start_app', 'view': 'app_delegate'}).sort('last_updated', pymongo.ASCENDING).skip(i).limit(limit)
# logs = log_collection.find({'action': 'became_active', 'view': 'app_delegate'}).sort('last_updated', pymongo.ASCENDING).skip(i).limit(limit)

# then, repeat with 'became_active' actions.


issues_to_publish = [ ]
if (len(sys.argv) > 1):
    action = sys.argv[1]
    
    if (action == 'info'):
        sys.stderr.write("You want to parse through the INFO packets.\n")
        utility.SWC.parse_for_info(50)
        utility.SWC.summarize_info_results()
        
    elif (action == 'info-purge'):
        utility.SWC.clear_info_results()
        utility.SWC.summarize_info_results()
        
        
    elif (action == 'feedback'):
        utility.SWC.parse_for_feedback(50)
        utility.SWC.list_feedback()
        utility.SWC.summarize_info_results()
        
        
    elif (action == 'feedback-purge'):
        utility.SWC.clear_feedback()
        sys.stderr.write("Feedback log records have been cleared.")
        
        
    

else:
    sys.stderr.write("At least one command line argument is required.  Options:\n")
    sys.stderr.write("\t info \t parses log data's \"info\" actions and aggregates data for unique device ids\n")
    sys.stderr.write("\t info-purge\t clears the flag that has indicated individual \"info\" log actions have been parsed for its info so you can run the above script again\n")
    sys.stderr.write("\t feedback\t parses the log's data \"feedback\" actions and aggregates it into your datastore's feedback collection\n")
    sys.stderr.write9"\t feedback-purge\t clears the flag that has indicated individual \"feedback\" log actions have been parsed for its feedback so you can run the above script again\n")



sys.stderr.write("\n** SCRIPT COMPLETE **\n")