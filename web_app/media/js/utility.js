
/***************************
* Copyright (c) 2012 29th Street Publishing, LLC.
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
* * Redistributions of source code must retain the above copyright notice,
*   this list of conditions and the following disclaimer.
*
* * Redistributions in binary form must reproduce the above copyright notice,
*   this list of conditions and the following disclaimer in the documentation
*   and/or other materials provided with the distribution.
*
* * Neither the name of 29th Street Publishing, LLC nor the names of its contributors may
*   be used to endorse or promote products derived from this software without
*   specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
* ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
* LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
* SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
* INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
* CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
******************************/

jQuery(document).ready(function () {


   jQuery.fn.api_root = function() {
      return $('#api_root').attr('value');
   };
   
   jQuery.fn.get_views = function() {
     
      views = [ ];
     
      $.getJSON($.fn.api_root + '/view/all', function(data) {                   
         for (var i = 0; i < data.length; i++) {
            views[i] = data[i]['name'];
         }
      });
      
      return views;               
   },
   
   
   // this will draw a line graph with the properly-formatted data_array.
   // data_array must be in the format of:
   //    [
   //       {
   //          'x': 123,
   //          'y': 12346
   //       } // etc
   //    ]
   jQuery.fn.draw_line_graph = function(data_array, div_name, max) {
      
      // Sizing and scales. 
        var w = 300,
            h = 200,
            x = pv.Scale
               .linear(data_array, function(d) { return d.x; })
               .range(0, w),
               
            y = pv.Scale
               .linear(0, max)
               .range(1, h)
               ;

        // The root panel. 
        var vis = new pv.Panel().canvas(div_name)
            .width(w)
            .height(h)
            .bottom(65)
            .left(65)
            .right(0)
            .top(45);

        // X-axis ticks. 
        vis.add(pv.Rule)
            .data(x.ticks())
            .visible(function(d){ return (d > 0); })
            .left(x)
            .strokeStyle("#eee")
          .add(pv.Rule)
            .bottom(-5)
            .height(5)
            .strokeStyle("#000")
          .anchor("bottom").add(pv.Label)
            .text(x.tickFormat);

        // Y-axis ticks. 
        vis.add(pv.Rule)
            .data(y.ticks(5))
            .bottom(y)
            .strokeStyle(function(d) {
               if (d) {
                  return "#eee";
               }
               return  "#000";
            })
          .anchor("left").add(pv.Label)
            .text(y.tickFormat);
            
            //attempting some axis labels
            // this is the y axis
            vis.add(pv.Label)
                .left(-65)
                .top(-5)
                .textAlign("left")
                .text("Time Spent in App");
            
            //this is the x axis    
            vis.add(pv.Label)
                .left(-65)
                .bottom(-5)
                .textAlign("left")
                .text("Sessions");

        // The line. 
        vis.add(pv.Line)
            .data(data_array)
            .left(function(d) { return x(d.x); })
            .bottom(function(d) { return y(d.y); })
            .lineWidth(3)
            .anchor("top").add(pv.Label)
               .text(function(d) {return d.y;} )
               .textMargin(-10)
               .textBaseline(function(d) {
                  return "top";
               });
               

        vis.render();
      
      
   },
   // parameters:
   //  data -- an array that has value and label pairs
   // usage: 
   //      $.fn.draw_graphs(data, div_name);
   jQuery.fn.draw_pie_chart = function(data, div_name) {      
       var flat_array = [ ];
       
       var nonzero_found = 0;
       for (var i = 0; i < data.length; i++) {
          flat_array[i] = data[i].value;
          if (flat_array[i] != 0) {
             nonzero_found = 1;
          }
       }
       if (!nonzero_found) {
          return;
       }
       
       console.log("[draw_pie_chart] flat_array = ", flat_array);

          // Sizing and scales. 
          var w = 250,
              h = 250,
              r = w / 2,
              a = pv.Scale.linear(0, pv.sum(flat_array)).range(0, 2 * Math.PI);

          // The root panel. 
          var vis = new pv.Panel().canvas(div_name)
              .width(w)
              .height(h);

          // The wedge, with centered label. 
          vis.add(pv.Wedge)
              .data(function() {              
                  values = [ ]
                  for (var i = 0; i < data.length; i++) {
                     values[i] = data[i].value;
                  }
                  return values;
                 })
              .bottom(w / 2)
              .left(w / 2)
              .innerRadius(0)
              .outerRadius(r)
              
              .angle(a)
              
              .event("mouseover", function() { return this.innerRadius(0); })
              

              .event("mouseout", function() { return this.innerRadius(0); })
            
            .anchor("center").add(pv.Label)
              .visible(1)
              .textAngle(0)
              .text(function(c, d, e) {
                 return Math.round(data[this.index].value) + "% " + data[this.index].label;
              });  

              vis.render();
   },
   
   jQuery.fn.fill_in_metadata = function(data, div_name) {       
      
      console.log("[fill_in_metadata] data = ", data);
      
      
      var rotations = data.summary.average_number_rotations;
      if (rotations < 0) {
         rotations = 0;
      }
      //rotations = rotations.replace(/^-/, '');
      
       $("." + div_name + "-average_number_rotations").append("<p>" + 
          rotations + "</p>");

       var rounded =  Math.round(parseFloat(data.summary.average_usage_time)*100)/100;
       
       $("." + div_name + "-average_usage_time").append("<p>" + 
          rounded + "</p>");
       
       if (data.device_type != undefined) {
          $("." + div_name + "-type").append("<strong>Device Type: </strong>" + data.device_type);   
       }
         
       $("." + div_name + "-last_access").append("<strong>Device Last Accessed:</strong> " + data.last_access);
           
       $("." + div_name + "-num_sessions").append("<strong>Total Number of Sessions:</strong> " + data.summary.num_sessions);
       
       $("." + div_name + "-usage_time").append("<strong>Total Time:</strong> " + data.usage_time);
       
       $("." + div_name + "-start_time").append("<strong>Start Time:</strong> " + data.start_time);
       
       $("." + div_name + "-end_time").append("<strong>End Time:</strong> " + data.end_time);
       
       $("." + div_name + "-total_usage_time").append("<strong>Total Time In Use:</strong> " + data.summary.total_usage_time);

   },
   
   
   jQuery.fn.fill_in_summary_table = function(data, div_name, app_url) {       
      
       $.each(data.sessions, function(i,item){
          $("table.index.sessions").append("<tr>" + "<td><a href='" + app_url + "/session/" + item.id + "'>" + item.id + "</a></td>" + "<td><a href='" + app_url + "/device/" + item.device + "'>" + item.device + "</a></td>" + "<td>" + item.start_time  + "</td>" + "<td>" + item.usage_time  + "</td>" + "</tr>");
       });
       
   },
   
   
   jQuery.fn.fill_in_session_table = function(data, div_name) {       
      
       $.each(data.logs, function(i,item){
          $("table.sessions").append("<tr><td>" + item.last_updated  + "</td>" + "<td>" + item.action  + "</td>" + "<td>" + item.view  + "</td>" + "<td>" + item.metadata  + "</td></tr>");
       });
       
   },
   
   jQuery.fn.fill_in_device_table = function(data, div_name, app_url) {       
      
       $.each(data.sessions, function(i,item){
          $("table.sessions").append("<tr><td>" + item.start_time  + "</td>" + "<td>" + item.usage_time  + "</td>" + "<td><a href='" + app_url + "/session/" + item.id + "'>" + item.id + "</a></td></tr>");
       });
       
   },
   
   jQuery.fn.fill_in_app_url = function(data, div_name, app_url) {       

         $("." + div_name + "-device").append("<strong>From Device:</strong> <a href='" + app_url + "/device/" + data.device + "'>" + data.device + "</a>");
         
     },
   

   
   jQuery.fn.line_chart_view_times = function(data, div_name) {
      data_array = [ ];

      max_usage = 0;

       for (var i = 0; i < data.sessions.length; i++) { 

          data_array[i] = {
             'x': i,
             'y': data.sessions[i]['usage_time']
          }
          
          if (data.sessions[i]['usage_time'] > max_usage) {
             max_usage = data.sessions[i]['usage_time'];
          }
       }

      $.fn.draw_line_graph(data_array, div_name, max_usage);
   },
   
   jQuery.fn.pie_chart_views = function(data, div_name, view_array)  {
      
      var new_data = [ ];
      
      for (var i = 0; i < view_array.length; i++) {
         new_data[i] = {
                 'value': parseFloat(data.summary.views[view_array[i]]),
                 'label': view_array[i]
         };
      }
      
      if (data.views.length > 0) {
         $.fn.draw_pie_chart(new_data, div_name + '-views');
      }
   },
   
   jQuery.fn.pie_chart_devices = function(data, div_name) {

      var types = data['summary']['device_types'];
      var keys = Object.keys(types);
      
      var new_data = [ ];
      
 
      for (var i = 0; i < keys.length; i++) {         
         var d = data['summary']['device_types'][keys[i]];
         var l = keys[i];
         
         console.log("data value = ", d);
         console.log("data label = ", l);
         
         new_data[i] = {
               'value': parseFloat(d),
               'label': l
         };
      }
      
      console.log("[pie_chart_devices] types = ", types);
       console.log("new data = ", new_data);
      
      var result2 = $.fn.draw_pie_chart(new_data, div_name);   
   }
   jQuery.fn.pie_chart_orientation = function(data, div_name)  {
        var data = [{
                 'value': parseFloat(data.summary.orientation['landscape-left']),
                 'label': 'Landscape Left'
               },
               {
                  'value': parseFloat(data.summary.orientation['landscape-right']),
                  'label': 'Landscape Right'
               },
               {
                  'value': parseFloat(data.summary.orientation['portrait-standard']),
                  'label': 'Portrait Standard'
               },
               {
                  'value': parseFloat(data.summary.orientation['portrait-upside-down']),
                  'label': 'Portrait Upside Down'
               }
              ];
      
      
         var result2 = $.fn.draw_pie_chart(data, div_name + '-orientation');
   },
   
   
   jQuery.fn.draw_device_data = function(device_url, average_url, app_url) {
      
      var views_array = $.fn.get_views(app_url);
      
      // first, get the device url's data.
      $.getJSON(device_url, function(data) {
            $.fn.fill_in_metadata(data, 'device');            
         
           // $.fn.pie_chart_views(data, 'device', views_array);
            $.fn.pie_chart_orientation(data, 'device');
            
            
            $.fn.line_chart_view_times(data, 'device-sessions');
            
            $.fn.fill_in_device_table(data, 'device', app_url);
            
      });   
      
      // then, draw the averages
      /*
      $.getJSON(average_url, function(data) {
            // this lists the averages.
            $.fn.fill_in_metadata(data, 'overall');
            
            $.fn.pie_chart_views(data, 'average', views_array);
            $.fn.pie_chart_orientation(data, 'average');  
            
            $.fn.line_chart_view_times(data, 'average-sessions');            
      });   
      */   
   }
   
   
   jQuery.fn.draw_session_data = function(session_url, average_url, app_url) {
      
      var views_array = $.fn.get_views(app_url);
      
      
      // first, get the session url's data.
      $.getJSON(session_url, function(data) {
            $.fn.fill_in_metadata(data, 'session');
         
         
            $.fn.pie_chart_views(data, 'session', views_array);
            $.fn.pie_chart_orientation(data, 'session');
            
            $.fn.fill_in_app_url(data, 'session', app_url);
            
            $.fn.fill_in_session_table(data, 'session');
            
            //$.fn.line_chart_view_times(data, 'session-sessions');
            
      });   
      
      // then, draw the averages

     /*
      $.getJSON(average_url, function(data) {
            // this lists the averages.
            $.fn.fill_in_metadata(data, 'overall');
            
            $.fn.pie_chart_views(data, 'average', views_array);
            $.fn.pie_chart_orientation(data, 'average');  
            
            $.fn.line_chart_view_times(data, 'average-sessions');            
      });   
      */   

   }
      
   jQuery.fn.draw_summary_data = function() {
       
      var average_url = $.fn_api_root + '/session/all';
      var views_array = $.fn.get_views();

      $.getJSON(average_url,
        function(data) { 
            
            //$.fn.pie_chart_views(data, 'average', views_array);
            $.fn.pie_chart_orientation(data, 'average');
            $.fn.pie_chart_devices(data, 'average-device-type');
            $.fn.fill_in_metadata(data, 'overall');                         
            $.fn.fill_in_summary_table(data, 'overall', app_url);
            
       });
      
   };
   
   jQuery.fn.draw_one_device_table = function(name, values, num_total) {
      
      console.log("draw_one_device_table = values = ", values);
      
      
      for (var i = 0; i < values.length; i++) {
          $("table.index.device-" + name).append(
             "<tr>" + 
               "<td>" +  values[i]['name'] + "</td>" + 
               "<td>" +  values[i]['number'] + "</td>" + 
               "<td>" +  (values[i]['number'] / num_total) * 100  + "%</td>" + 
               
            "</tr>"              
          );
      }
   }
   
   jQuery.fn.draw_device_summary = function() {
      var device_url = $.fn.api_root() + '/device.json';

      $.getJSON(device_url,
        function(data) {            
           var parameters = ['timezones', 'ios_version', 'types', 'versions'];
           for (var i = 0; i < parameters.length; i++) {
              $.fn.draw_one_device_table(parameters[i], data[parameters[i]]['values'], data['num_devices']);
           }
            
           // update the device count.
           $('#device_count').html("<p>We have data for <b>" + data['num_devices'] + "</b> unique devices.</p>")
            
       });
   }
   
   
   
   // $.fn.draw_summary_data('');
   
   
   $.fn.draw_device_summary();
   
   
}); 


jQuery(document).ready(function () {
  });
