var ICQ = (function() {

    var freeresponse_show = function(data, answer) {
        var arr = [];
        for (var key in data) {
            arr.push([key, data[key]]);
        }
        arr.sort(function(a, b) { return b[1]-a[1] });
        var s = "<ul id='freeresponse_list'>"
        jQuery("#freeresponse_list").remove();
        var alen = arr.length;
        for (var i = 0; i < alen; i++) {
            s += "<li>" + arr[i][0] + " (" + arr[i][1] + ")</li>";
        }
        s += "</ul>"
        jQuery("#plotspace").append(s);
    };

    var mkarray = function(data) {
        var arr = [];
        for (var key in data) {
            var count = data[key];
            for (var i = 0; i < count; i++) {
                arr.push(+key);
            }
        }
        arr.sort(function(a, b) { return a-b });
        return arr;
    };

    var boxwhiskers = function(data, answer) {
        var arr = mkarray(data);
        var height = 300;
        var width = 300;

        var boxmin = d3.quantile(arr, 0.25);
        var median = d3.quantile(arr, 0.50);
        var boxmax = d3.quantile(arr, 0.75);
        var low = d3.quantile(arr, 0.05);
        var high = d3.quantile(arr, 0.95);

        var aval = answer;
        if (answer === null) {
            aval = arr[0];
        }
        aval = +aval;

        var minv = d3.min(arr);
        minv = aval < minv ? aval : minv;
        var maxv = d3.max(arr);
        maxv = aval > maxv ? aval : maxv;
        var range = maxv-minv;
        minv = minv - range*0.1;
        maxv = maxv + range*0.1;
        /*
        console.log(minv);
        console.log(maxv);
        console.log(median);
        */

        var y = d3.scaleLinear().
            domain([minv-minv*0.05, maxv+maxv*0.05]).
            range([height, 0]);

        var svg = d3.select("#plotspace").
            append("svg:svg").
            attr("width", width).
            attr("height", height);
        
        // box
        var color = d3.schemeCategory10[0];
        var box = d3.path();
        box.moveTo(100, y(boxmin));
        box.lineTo(200, y(boxmin));
        box.lineTo(200, y(boxmax));
        box.lineTo(100, y(boxmax));
        box.lineTo(100, y(boxmin));
        box.closePath();
        svg.append("path").attr("d", box).attr("stroke", color).attr("fill", "none");

        // bottom whisker
        var lower = d3.path();
        lower.moveTo(150, y(low));
        lower.lineTo(150, y(boxmin));
        lower.closePath();
        // top whisker
        var upper = d3.path();
        upper.moveTo(150, y(boxmax));
        upper.lineTo(150, y(high));
        upper.closePath();
        svg.append("path").attr("d", upper).attr("stroke", "blue");
        svg.append("path").attr("d", lower).attr("stroke", "blue");
        // median line
        var midline = d3.path();
        midline.moveTo(100, y(median));
        midline.lineTo(200, y(median));
        midline.closePath();
        svg.append("path").attr("d", midline).attr("stroke", "red");
        // answer line
        if (answer !== null) {
            var ansline = d3.path();
            ansline.moveTo(50, y(answer));
            ansline.lineTo(250, y(answer));
            ansline.closePath();
            svg.append("path").
                classed("answer", true).
                style("display", "none").
                attr("d", ansline).
                attr("stroke", "green");
        }

        var axis = d3.axisRight(y);
        svg.append("g").
            attr("stroke", "black").
            call(axis);
    };

    var reformat_data = function(d) {
        arr = [];
        for (var key in d) {
            xh = {'option': key, 'value': d[key]}
            arr.push(xh);
        }
        return arr;
    }

    var horizontal_bar = function(data, answer) {
        var barHeight = 40;
        var data = reformat_data(data);
        var dlen = data.length;
        var height = (barHeight + 25) * dlen;
        var width = 400;
        var ansindex = -1;
        if (answer !== null) {
            for (var i = 0; i < dlen; i++) {
                if (answer === data[i].option) {
                    ansindex = i;
                    break;
                }
            }
        }

        var y = d3.scaleLinear().domain([-0.5, dlen]).range([0, height]);
        var x = d3.scaleLinear().domain([0, d3.max(data, function(datum) { return datum.value; })*1.2]).rangeRound([0, width]);

        var svg = d3.select("#plotspace").
                append("svg:svg").
                attr("width", width).
                attr("height", height);

        svg.selectAll("rect").
            data(data).
            enter().
            append("svg:rect").
            attr("y", function(datum, index) { return y(index); }).
            attr("x", 0).
            attr("width", function(datum) { return x(datum.value); }).
            attr("height", barHeight).
            attr("fill", function(d, idx) { return d3.schemeCategory10[idx]; });

        // svg.selectAll("text").
        //     data(data).
        //     enter().
        //     append("svg:text").
        //     attr("y", function(datum, index) { return y(index) + barHeight; }).
        //     attr("x", width*0.85).
        //     attr("dy", -barHeight/2).
        //     attr("dx", "1.2em").
        //     attr("text-anchor", "middle").
        //     attr("style", "font-size: 12; font-family: Helvetica, sans-serif").
        //     text(function(datum) { return datum.value;}).
        //     attr("fill", "black");

        svg.selectAll("text.yAxis").
            data(data).
            enter().append("svg:text").
            attr("y", function(datum, index) { return y(index) + barHeight; }).
            attr("x", width*0.05).
            attr("dy", -barHeight/2).
            attr("text-anchor", "left").
            attr("style", "font-size: 14; font-family: Helvetica, sans-serif").
            text(function(datum) { return datum.option; }).
            attr("class", "yAxis").
            attr("fill", "black");
       
        var axis = d3.axisTop(x);
        var ymove = height * 0.99;
        svg.append("g").
            attr("stroke", "black").
            attr("transform", "translate(0, "+ymove+")").
            call(axis);

        if (ansindex > -1) {
            var ansline = d3.path();
            ansline.arc(5, y(ansindex+0.4), 5, 0, 360);
            ansline.closePath();
            svg.append("path").
                classed("answer", true).
                style("display", "none").
                attr("d", ansline).
                attr("fill", "black").
                attr("stroke", "black");
        }
    };

    var student_response_handler = function(ev) {
      var detail = ev.detail;
      var data = detail[0];
      jQuery("#railsflash").hide();
      jQuery("#jsflash").css("opacity", 1.0);
      jQuery("#jsflash").text(data.message);
      jQuery("#jsflash").show();
      jQuery("#jsflash").addClass("alert");
      jQuery("#jsflash").addClass("alert-info");
      jQuery("#jsflash").fadeTo(500, 0.5);
    };

    var drawresponse = function(ev) {
      var detail = ev.detail;
      var data = detail[0];
      // console.log(data);
      var rcount = 0;
      var counts = Object.values(data.responses);
      // console.log(counts);
      for (var i = 0; i < counts.length; i++) {
          rcount += counts[i];
      }
      jQuery("#responsecount").text(rcount);
      var plotfn = {"MultiChoicePoll": horizontal_bar, "NumericPoll": boxwhiskers, "FreeResponsePoll": freeresponse_show};
      jQuery("#plotspace > svg").remove();
      plotfn[data.type](data.responses, data.answer);
    };

    var status_update = function(data, tstatus, jqxhr) {
        /*
        console.log("status update");
        console.log(data);
        */
        if (ICQ.questionstatus === undefined) {
           ICQ.questionstatus = data.status; 
        }

        if (ICQ.questionstatus != data.status) {
            console.log("Modifying location");
            window.location = window.location.href;
        }

        /*
        if (data.status == 'open') {
            if (data.path != window.location.pathname) {
              console.log("Modifying location");
              // window.location = window.location.origin + data.path;
            }
        } else if (data.status == 'closed') { 
            if (data.path != window.location.pathname) {
              console.log("Modifying location");
              window.location = window.location.origin + data.path;
            }
        } 
        */
    };

    var monitor_question_status = function(ids) {
        var url = "/courses/" + ids[0] + "/questions/" + ids[1] + "/polls/" + ids[2] + "/status";

        // if no question is active, question/poll ids are both 0
        if (ids[1] == "0") {
            url = "/courses/" + ids[0] + "/status";
        }

        jQuery.ajax({
            'url': url,
            'dataType': 'json',
            'success': status_update,
        });

        setTimeout(monitor_question_status, 1000, ids);
    };

    var add_option_textbox = function(){
        console.log("Am here");
        jQuery("#display").innerHTML = jQuery("#display").innerHTML + "got here!";
    };

    return {
        init: function() {
            jQuery("#question_type").on('change', function() {
                if (jQuery("#question_type").val() == "MultiChoiceQuestion") {
                    jQuery("#question_qcontent").show();
                } else {
                    jQuery("#question_qcontent").hide();
                }
            });
            jQuery("#notify").on('ajax:success', function() {
                jQuery("#notify").removeClass("btn-warning");
                jQuery("#notify").addClass("btn-primary");
            });
            jQuery("#notify").on('ajax:failure', function() {
                jQuery("#notify").removeClass("btn-warning");
                jQuery("#notify").addClass("border-danger");
            });
            jQuery("#notify").on('click', function() {
                jQuery("#notify").removeClass("btn-primary");
                jQuery("#notify").addClass("btn-warning");
            });

            jQuery("#responseunfold").on('click', function() {
                jQuery("#responses").toggle();
            });
            jQuery("#showanswer").on('click', function() {
                jQuery(".answer").toggle();
            });
            
            
            jQuery(document).ready(function() {

                jQuery(".add_field_button").click(function(e){ //on add input button click
                    e.preventDefault();
                    jQuery('.input_fields_wrap').append('<div><input class="option_input "type="text" name="mytext[]"/><a href="#" class="remove_field">Remove</a></div>'); //add input box
                });
    
                jQuery(".input_fields_wrap").on("click",".remove_field", function(e){ //user click on remove text
                    e.preventDefault(); 
                    jQuery(this).parent('div').remove();
                });
                
                jQuery(".save_fields_button").click(function(e){
                    e.preventDefault();
                    options = []
                    jQuery("input[type=text].option_input").each(function(){
                        options.push(jQuery(this).val());
                    });
                    jQuery("#qcontent").val(options.join("\n"));
                });
            });
            
            
            jQuery("#new_free_response_poll_response").on('ajax:success', student_response_handler);
            jQuery("#new_multi_choice_poll_response").on('ajax:success', student_response_handler);
            jQuery("#new_numeric_response_poll_response").on('ajax:success', student_response_handler);
            jQuery("#responsesync").on('ajax:success', drawresponse);
            if (document.getElementById("squestion") !== null) {
                var ids = jQuery("#squestion").attr('data-ids').split(/ /);
                if (ids.length == 3) {
                    monitor_question_status(ids);
                }
            }
        },
    }

}());
ICQ.questionstatus = undefined;

// window.addEventListener('DOMContentLoaded', ICQ.init);

jQuery(ICQ.init);
