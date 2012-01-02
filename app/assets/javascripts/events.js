// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


    $(document).ready(function(){
     // alert('ready');
        // page is now ready, initialize the calendar...
        $('#calendar').fullCalendar({
            editable: true,
            header: {
                left: 'prev,next today',
                center: 'title',
                right: 'month,agendaWeek,agendaDay'
            },
            defaultView: 'agendaWeek',
            height: 500,
            slotMinutes: 15,
            loading: function(bool){
                if (bool) 
                    $('#loading').show();
                else 
                    $('#loading').hide();
            },
            events: "/events/get_events",
            timeFormat: 'h:mm t{ - h:mm t} ',
            dragOpacity: "0.5",
            eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc){
  //              if (confirm("Are you sure about this change?")) {
                    moveEvent(event, dayDelta, minuteDelta, allDay);
  //              }
  //              else {
  //                  revertFunc();
  //              }
            },

            eventResize: function(event, dayDelta, minuteDelta, revertFunc){
  //              if (confirm("Are you sure about this change?")) {
                    resizeEvent(event, dayDelta, minuteDelta);
  //              }
  //              else {
  //                  revertFunc();
  //              }
            },

            eventClick: function(event, jsEvent, view){
                showEventDetails(event);
            },




        });
    });



function moveEvent(event, dayDelta, minuteDelta, allDay){
    jQuery.ajax({
        data: {
          id:           event.id, 
          title:        event.title, 
          day_delta:    dayDelta,
          minute_delta: minuteDelta,
          all_day:      allDay
        },
        dataType: 'script',
        type: 'post',
        url: move_events_path
    });
}

function resizeEvent(event, dayDelta, minuteDelta){
    jQuery.ajax({
        data: {
          id:           event.id, 
          title:        event.title, 
          day_delta:    dayDelta,
          minute_delta: minuteDelta
        },
        dataType: 'script',
        type: 'post',
        url: resize_events_path
    });
}

function showEventDetails(event){
    $('#event_desc').html(event.description);
    $('#edit_event').html("<a href = 'javascript:void(0);' onclick ='editEvent(" + event.id + ")'>Edit</a>");
    if (event.recurring) {
        title = event.title + "(Recurring)";
        $('#delete_event').html("&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + false + ")'>Delete Only This Occurrence</a>");
        $('#delete_event').append("&nbsp;&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + true + ")'>Delete All In Series</a>")
        $('#delete_event').append("&nbsp;&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", \"future\")'>Delete All Future Events</a>")
    }
    else {
        title = event.title;
        $('#delete_event').html("<a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + false + ")'>Delete</a>");
    }
    $('#desc_dialog').dialog({
        title: title,
        modal: true,
        width: 500,
        close: function(event, ui){
            $('#desc_dialog').dialog('destroy')
        }
        
    });
    
}


function editEvent(event_id){
    jQuery.ajax({
        //data: 'id=' + event_id,
        dataType: 'script',
        type: 'get',
        url: Routes.edit_event_path(event_id)
    });
}



function deleteEvent(event_id, delete_all){
    jQuery.ajax({
        //data: 'id=' + event_id + '&delete_all='+delete_all,
        dataType: 'script',
        type: 'delete',
        url: event_path(event_id,{delete_all: delete_all})
    });
}

function showPeriodAndFrequency(value){

    switch (value) {
        case 'Daily':
            $('#period').html('day');
            $('#frequency').show();
            break;
        case 'Weekly':
            $('#period').html('week');
            $('#frequency').show();
            break;
        case 'Monthly':
            $('#period').html('month');
            $('#frequency').show();
            break;
        case 'Yearly':
            $('#period').html('year');
            $('#frequency').show();
            break;
            
        default:
            $('#frequency').hide();
    }
    
    
    
    
}