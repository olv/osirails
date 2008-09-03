/* Globals */
draggables_events = new Array();
event_box_id = "event_box";
event_box_content_id = "event_box_content";
recur_message = "<b>Modification d’un événement récurrent</b><br /><span>La modification de l’heure d’un événement récurrent est en cours. Souhaitez-vous reporter uniquement cette occurrence ou bien modifier l’heure de celle-ci et de tous les événements futurs ?</span>";
recur_delete_message = "<b>Supprimer l'événement</b><br /><span>Souhaitez-vous supprimer cet événement ainsi que toutes ses occurrences futures ou uniquement celle sélectionnée ?</span>"

/* Functions */

/* Initialization of the calendar */
/* p must be: 'day' or 'week' or 'year' */
function calendar_init (db_id, p, p_b, p_d, p_w, p_m, p_a, g_e) {
  db_calendar_id = db_id;
  period = p;
  link_period_before = p_b;
  link_period_day = p_d;
  link_period_week = p_w;
  link_period_month = p_m;
  link_period_after = p_a;
  link_get_events = g_e;
  document.getElementById('grid_' + period).setAttribute('onDblClick', "display_event_box('new', null, event)");
  if (period != 'month') {
    document.getElementById('scroll').scrollTop = 480;
    document.body.setAttribute('onResize', "resize_events();");
  };
  ajax_link(link_get_events);
}

/* Display an event on the calendar. This function is used by the server */
/* id         database id */
/* color      CSS color */
/* week_day   the date of the event. Example: 20080920 */
/* full_day   boolean */
function add_event (id, title, top, height, color, week_day, full_day) {
  var elm_id = 'event' + id

  if (period == 'month') {
    var events = document.getElementsByClassName('event_month');
    for (var i=0; i < events.length; i++) {
      if (events[i].id == elm_id) {
        events[i].parentNode.removeChild(events[i]);
      };
    };

    var ul_elm = document.getElementById(week_day).childNodes[2];
    var li_elm = document.createElement('li');
    li_elm.setAttribute('id', elm_id);
    li_elm.setAttribute('class', 'event_month');
    li_elm.style.color = color;
    li_elm.innerHTML = title;
    li_elm.setAttribute('ondblclick', 'display_event_box(\'show\', \''+ elm_id +'\', event);');
    ul_elm.appendChild(li_elm);
    
    add_draggable(elm_id);
  } else {
    var events = document.getElementsByClassName('event');
    for (var i=0; i < events.length; i++) {
      if (events[i].id == elm_id) {
        events[i].ancestors()[1].removeChild(events[i].parentNode);
      };
    };

    var grid_day = document.getElementById(week_day).childNodes[1].firstChild;
    var event_div = document.createElement('div');
    var event_content = document.createElement('div');
    var li_elm = document.createElement('li');

    event_div.setAttribute('id', elm_id);
    event_div.setAttribute('class', 'event');
    event_div.setAttribute('style', 'top: ' + top + 'px; height: ' + height + 'px; background-color: ' + color);
    event_div.setAttribute('ondblclick', 'display_event_box(\'show\', \''+ elm_id +'\', event);');

    event_content.setAttribute('class', 'event_content');

    event_content.innerHTML = "<span name='start_at' class='start_at'></span>-<span name='end_at' class='end_at'></span><br /><span name='title' class='title'>" + title + "</span>";

    event_div.appendChild(event_content);
    li_elm.appendChild(event_div);
    grid_day.appendChild(li_elm);

    //Effect.Pulsate(elm_id, { pulses: 2, duration: 1 });

    add_draggable(elm_id);
    new Resizeable(elm_id, {
      left:0,
      right:0,
      top: 0,
      bottom: 4,
      minHeight: 19,
      resize: function() {
        update_time(elm_id);
        save_event(elm_id);
      }
    });
    update_time(elm_id);	  
  };
}

/* The event id passed in argument, will be draggable with the correct */
/* options */
function add_draggable (elm_id) {
  if (period == 'month') {
    new Draggable(elm_id, { revert: true });
  } else {
    draggables_events.push(new Draggable(elm_id, {
      handle: document.getElementById(elm_id).firstChild,
      snap: [document.getElementById('grid_' + period).childNodes[1].offsetWidth, 15],
      change: function(draggable) {
        grid_area(draggable);
        drag_and_scroll(draggable.element.id);
      },
      onDrag: function(draggable) {
        update_time(draggable.element.id);
      },
      onEnd: function(draggable) {
        change_day_events(draggable);
        save_event(draggable.element.id);
      }
      }));
    };
  }

  /* This function unauthorize an event passed in argument to exceed the grid */ /* area */
  function grid_area(draggable) {
    var cal_event = draggable.element;
    var coeff = get_position(cal_event.ancestors()[3].id);
    var grid_elm = document.getElementById('grid_' + period);

    var left_size = parseInt(cal_event.style.left);
    var left_max_size = (6 - coeff) * (cal_event.offsetWidth);
    if (left_size > left_max_size) {
      cal_event.style.left = left_max_size + "px";
    };
    var left_min_size = - coeff * (cal_event.offsetWidth);
    if (left_size < left_min_size) {
      cal_event.style.left = left_min_size + "px";
    };
    var top_size = parseInt(cal_event.style.top);
    var top_max_size = grid_elm.offsetHeight - cal_event.offsetHeight - 2;
    if (top_size > top_max_size) {
      cal_event.style.top = top_max_size + "px";
    };
    if (top_size < 0) {
      cal_event.style.top = "0px";
    };
  }

  /* Update the correct time of an event. The function use the event's style */
  function update_time (id) {
    var eventss = document.getElementsByClassName('event');
    for (var i=0; i < eventss.length; i++) {
      id = eventss[i].id;

      element = document.getElementById(id);
      var left_size = parseInt(element.style.left);
      var top_size = parseInt(element.style.top);
      var height = element.offsetHeight;

      var start_at_hour = ((top_size - top_size % 60) / 60);
      var start_at_min = (top_size % 60);

      var temp_diff = top_size + height;
      var end_at_hour = ((temp_diff - temp_diff % 60) / 60);
      var end_at_min = (temp_diff % 60);

      var start_at = start_at_hour + "h" + start_at_min;
      var end_at = end_at_hour + "h" + end_at_min;

      element.firstChild.childNodes[0].innerHTML = start_at;
      element.firstChild.childNodes[2].innerHTML = end_at;
    };
  }

  /* This function are exececuted when the window is resizing */
  /* It permit events to have the correct snap */
  function resize_events () {
    for (var i=0; i < draggables_events.length; i++) {
      draggables_events[i].destroy();
    };
    var events = document.getElementsByClassName('event');
    for (var i=0; i < events.length; i++) {
      add_draggable(events[i].id);
    };
  }

  /* This function move an event passed in argument, to the correct day's div */
  function change_day_events (draggable) {
    var	cal_event = draggable.element;
    var left_size = parseInt(cal_event.style.left);
    var day_num = get_position (cal_event.ancestors()[3].id);
    var target_day = day_num + (left_size / cal_event.ancestors()[1].offsetWidth);
    var day = cal_event.ancestors()[4].childNodes[target_day * 2 + 1];
    cal_event.style.left = 0;
    var events = document.getElementsByClassName('event');
    for (var i=0; i < events.length; i++) {
      if (events[i].id == cal_event.id) {
        events[i].id = "event" + day.id + cal_event.id.substr(13, cal_event.id.length - 13);
        cal_event.id = events[i].id;
      };
    };
    day.childNodes[1].childNodes[0].appendChild(cal_event.ancestors()[0]);
  }

  /* Reload every events */
  function reload_events () {
    clear_events();
    ajax_link(link_get_events);
  }

  /* Open the event box, who permit to show and edit an event */
  function display_event_box (action, event_id, event) {
    var event_box_elm = document.getElementById(event_box_id);
    switch (action) {
      case "show":
      for (var i=0; i < event.target.ancestors().length; i++) {
        if (event.target.ancestors()[i].className == 'event')
        {
          var db_event_id = event_id.substr(13, event_id.length - 13);
          ajax_link('/calendars/' + db_calendar_id + '/events/' + db_event_id + '&date=' + event_id.substr(5, 8), null, 'event_box');
          break;
        };
      };
      break;
      case "new":
      var top = event.pageY + document.getElementById('scroll').scrollTop - document.getElementById('grid_' + period).offsetTop;
      if (top >= 23 * 60) { top = 23 * 60; };
      if (event.target.className == "day_grid_border") {
        var date = event.target.parentNode.id;
        var temp_event_id = date + "new";
        var event_id = 'event' + temp_event_id;
        ajax_link('/calendars/' + db_calendar_id + '/events/new?top=' + top +'&height=' + 60 + '&date=' + date, null, 'event_box')
        add_event(temp_event_id, 'Nouvel événement', top, 50, 'blue', event.target.parentNode.id, false);
      };
      break;
    };
    document.getElementById(event_id).parentNode.appendChild(event_box_elm);
    event_box_elm.style.top = document.getElementById(event_id).style.top;
    event_box_elm.style.visibility = 'visible';
    event_box_elm.style.display = 'none';
    Effect.Appear(event_box_id, {direction: 'center'});
  }

  /* Close the event box */
  function hide_event_box () {
    var event_box_elm = document.getElementById(event_box_id);
    Effect.Fade(event_box_id, {duration: 0.3});
    setTimeout(function() {
      document.getElementById('calendar').appendChild(event_box_elm);
      event_box_loading();
      }, 300);
      var events = document.getElementsByClassName('event');
      for (var i=0; i < events.length; i++) {
        if (events[i].id.substr(13, 3) == 'new') {
          events[i].ancestors()[1].removeChild(events[i].parentNode);
        };
      };
    }

    /* Save to the database the event position */
    function save_event (elm_id) {
      cal_event = document.getElementById(elm_id);
      event_id = elm_id.substr(13, elm_id.length - 13);
      date = cal_event.ancestors()[0].ancestors()[0].ancestors()[1].id;
      if (is_recur_event(elm_id)) {
        var only = new LertButton('Uniquement cette événement', function() {
          ajax_link('/calendars/' + db_calendar_id + '/events/' + event_id +'?top=' + parseInt(cal_event.style.top) +'&height=' + (parseInt(cal_event.style.height) + 10) + '&date=' + date + '&recur=only', 'put');
        });

        var future = new LertButton('Tous les événements futurs', function() {
          ajax_link('/calendars/' + db_calendar_id + '/events/' + event_id +'?top=' + parseInt(cal_event.style.top) +'&height=' + (parseInt(cal_event.style.height) + 10) + '&date=' + date + '&recur=future', 'put');
        });

        var cancel = new LertButton('Annuler', function() {
          reload_events();
        });


        var exampleLert = new Lert(
          recur_message,
          [cancel, future, only],
          {
            defaultButton: only,
            icon:'/javascripts/lert-1.0/i/dialog-warning.png'
          });

          exampleLert.display();
        } else {
          if (ajax_link('/calendars/' + db_calendar_id + '/events/' + event_id +'?top=' + parseInt(cal_event.style.top) +'&height=' + (parseInt(cal_event.style.height) + 10) + '&date=' + date, 'put')) {
            // TODO Manage error
          };
        };
      }

      /* Get the position day of an event. Example: return 1 if the day of an */
      /* event is Monday */
      function get_position (elm_id) {
        var grid_elm = document.getElementById('grid_' + period)
        var days_num = grid_elm.childNodes.length
        for (var i=0; i < days_num; i++) {
          if (grid_elm.childNodes[i].id == elm_id) {
            return ((i - 1) / 2);
          };
        };
        return 0;
      }

      /* When an event is scrolled at the bottom or the top of the scroll. */
      /* The calendar is scrolling to the correct direction */
      function drag_and_scroll (elm_id) {
        var event_elm = document.getElementById(elm_id);
        var scroll_elm = document.getElementById('calendar').childNodes[9];
        var event_top = parseInt(event_elm.style.top);
        var event_height = parseInt(event_elm.style.height);
        var scroll_height = 600;
        if (event_top <= scroll_elm.scrollTop) {
          scroll_elm.scrollTop = event_top;
        } else if ((event_top + event_height) >= (scroll_elm.scrollTop + scroll_height)) {
          scroll_elm.scrollTop = event_top + event_height - scroll_height;
        };
      }

      /* Remove all the event from the displaying calendar */
      function clear_events () {
        var events = document.getElementsByClassName('event');
        for (var i=0; i < events.length; i++) {
          events[i].ancestors()[1].removeChild(events[i].parentNode);
        };
      }

      /* Show the loading message in the event box */
      function event_box_loading () {
        document.getElementById(event_box_content_id).innerHTML = "<img src=\"/images/loading.gif\" /> Chargement";
      }

      /* Show the error message in the event box */
      function event_box_failure () {
        document.getElementById(event_box_content_id).innerHTML = "Erreur lors du chargement, veueillez réessayer";
      }

      /* In the edit form of an event. This function manage some select of this */
      /* event */
      function event_change (argument, select_elm) {
        var frequence_elm = document.getElementById('event_frequence');
        var limit_elm = document.getElementById('event_frequence_limit')
        var custom_elm = document.getElementById('event_frequence_custom');

        switch(argument) {
          case "frequence":
          switch (select_elm.options[select_elm.selectedIndex].text) {
            case "Chaque jour":
            frequence_elm.value = "DAILY";
            break;
            case "Chaque semaine":
            frequence_elm.value = "WEEKLY";
            break;
            case "Tous les mois":
            frequence_elm.value = "MONTHLY";
            break;
            case "Tous les ans":
            frequence_elm.value = "YEARLY";
            break;
            default:
            frequence_elm.value = "";
            break;
          }
          if (select_elm.options[select_elm.selectedIndex].text == "Jamais") {
            limit_elm.style.display = "none";
          } else {
            limit_elm.style.display = 'block';
          };

          if (select_elm.options[select_elm.selectedIndex].text == "Personnaliser") {
            custom_elm.style.display = 'block';
          } else {
            custom_elm.style.display = 'none';
          };
          break;

          case "limit":
          var limit_select_elm = limit_elm.childNodes[3];
          var until_date_elm = document.getElementById('event_until_date').parentNode;
          var count_elm = document.getElementById('event_count').parentNode;
          switch(select_elm.options[select_elm.selectedIndex].text) {
            case "Jamais":
            until_date_elm.style.display = 'none';
            count_elm.style.display = 'none';
            break;
            case "Après":
            until_date_elm.style.display = 'none';
            count_elm.style.display = 'block';
            break;
            case "le":
            until_date_elm.style.display = 'block';
            count_elm.style.display = 'none';
            break;
          };
          break;

          case "custom":

          var custom_select_elm = custom_elm.childNodes[1].childNodes[1];
          //var custom_input_elm = custom_elm.firstChild.childNodes[2];
          var daily_elm = document.getElementById('event_daily');
          var weekly_elm = document.getElementById('event_weekly');
          var monthly_elm = document.getElementById('event_monthly');
          var yearly_elm = document.getElementById('event_yearly');
          switch(select_elm.options[select_elm.selectedIndex].text) {
            case "quotidienne":
            frequence_elm.value = "DAILY";
            daily_elm.style.display = 'block';
            weekly_elm.style.display = 'none';
            monthly_elm.style.display = 'none';
            yearly_elm.style.display = 'none';
            break;
            case "hebdomadaire":
            frequence_elm.value = "WEEKLY";
            daily_elm.style.display = 'none';
            weekly_elm.style.display = 'block';
            monthly_elm.style.display = 'none';
            yearly_elm.style.display = 'none';
            break;
            case "mensuelle":
            frequence_elm.value = "MONTHLY";
            daily_elm.style.display = 'none';
            weekly_elm.style.display = 'none';
            monthly_elm.style.display = 'block';
            yearly_elm.style.display = 'none';
            break;
            case "annuelle":
            frequence_elm.value = "YEARLY";
            daily_elm.style.display = 'none';
            weekly_elm.style.display = 'none';
            monthly_elm.style.display = 'none';
            yearly_elm.style.display = 'block';
            break;
          };
          break;
        };
      }

      /* Create an ajax request */
      function ajax_link (l, m, type) {
        switch (type) {
          case 'event_box':
          new Ajax.Request(l, {asynchronous:true, evalScripts:true, method: (m || 'get'), onLoading: "event_box_loading();", onFailure: "event_box_failure();"});
          break;
          default:
          new Ajax.Request(l, {asynchronous:true, evalScripts:true, method: (m || 'get'), onFailure: "alert('Erreur Ajax');"});
          break;
        }
      }

      /* Select the correct navigation period button's */
      function navig_selected (l, elm) {
        var all_buttons = document.getElementsByClassName("cal-buttons selected");
        for (var i=0; i < all_buttons.length; i++) {
          all_buttons[i].className = "cal-buttons";
        };
        elm.className = "cal-buttons selected";
        ajax_link(l);
      }

      /* Manage the type of date field */
      function full_day_checked (object) {
        var start_at_elm = document.getElementById('event_start_at');
        var end_at_elm = document.getElementById('event_end_at');

        if (object.checked) {
          start_at_elm.value = start_at_elm.value.substr(0, 10);
          end_at_elm.value = end_at_elm.value.substr(0, 10);
          Calendar.setup({ 
            inputField : "event_start_at",
            ifFormat : "%Y-%m-%d",
            timeFormat : "24"
          });
          Calendar.setup({ 
            inputField : "event_end_at",
            ifFormat : "%Y-%m-%d",
            timeFormat : "24"
          });
        } else {
          Calendar.setup({ 
            inputField : "event_start_at",
            ifFormat : "%Y-%m-%d %H:%M:%S",
            showsTime : true,
            timeFormat : "24"
          });
          Calendar.setup({ 
            inputField : "event_end_at",
            ifFormat : "%Y-%m-%d %H:%M:%S",
            showsTime : true,
            timeFormat : "24"
          });
        };
      }

      /* Move a full day event to the full day bar */
      function full_day_event (event_elm, boolean) {
        var day_elm = event_elm.ancestors()[3];
        if (boolean) {

        } else {

        };
      }

      /* Manage the select of the event's alarm */
      function alarm_selected (object) {
        var alarm_elm = document.getElementById('alarm');
        var alarm_display_elm = document.getElementById('alarm_display');
        var alarm_email_elm = document.getElementById('alarm_email');
        switch (object.selectedIndex) {
          case 0:
          alarm_elm.style.display = 'none';
          alarm_display_elm.style.display = 'none';
          alarm_email_elm.style.display = 'none';
          break;
          case 1:
          alarm_elm.style.display = 'block';
          alarm_display_elm.style.display = 'block';
          alarm_email_elm.style.display = 'none';
          break;
          case 2:
          alarm_elm.style.display = 'block';
          alarm_display_elm.style.display = 'none';
          alarm_email_elm.style.display = 'block';
          break;
        };
      }

      /* Remove all the children of the event box, who have a "display: none;" */
      /* style's */
      function submit_event_box_form (elm) {  
        document.getElementById('recur_date').value = elm.ancestors()[7].id;

        var event_box_content_elm = document.getElementById('event_box_content');
        remove_undisplayed(event_box_content_elm);
      }

      /* Recursive function for the previous function */
      function remove_undisplayed (elm) {
        if (elm) {
          if (elm.tagName == 'DIV' && elm.style.display == 'none') {
            elm.parentNode.removeChild(elm);
          } else {
            for (var i=0; i < elm.childNodes.length; i++) {
              remove_undisplayed(elm.childNodes[i]);
            };
          };
        };
      }

      /* Indicate if the event is a recur event or not */
      function is_recur_event (event_id) {
        var all_events = document.getElementsByClassName('event');
        var db_event_id = event_id.substr(13, event_id.length - 13);
        for (var i=0; i < all_events.length; i++) {
          if (all_events[i].id != event_id) {
            var tmp_id = all_events[i].id.substr(13, all_events[i].id.length - 13);
            if (db_event_id == tmp_id) { return true; };
          };
        };
        return false;
      }

      /* Verify if the user want to modify only this event or all the recurrence */
      function event_box_edit_date (elm, db_event_id) {
        var recur_elm = document.getElementById('recur');
        if (is_recur_event('event'+ elm.ancestors()[6].id + db_event_id) && recur_elm.value == '') {
          var only = new LertButton('Uniquement cette événement', function() {
            recur_elm.value = 'only';
          });
          var future = new LertButton('Tous les événements futurs', function() {
            recur_elm.value = 'future';
          });
          var cancel = new LertButton('Annuler', function() {

          });

          var exampleLert = new Lert(
            recur_message,
            [cancel, future, only],
            {
              defaultButton: only,
              icon:'/javascripts/lert-1.0/i/dialog-warning.png'
            });

            exampleLert.display();
          };
        }

        function event_box_delete (elm, db_event_id) {
          if (is_recur_event('event'+ elm.ancestors()[5].id + db_event_id)) {
            var only = new LertButton('Uniquement cette événement', function() {
              ajax_link('/calendars/' + db_calendar_id + '/events/' + db_event_id + '?delete=1&recur=only&date=' + elm.ancestors()[5].id, 'put');
            });
            var future = new LertButton('Tous les événements futurs', function() {
              ajax_link('/calendars/' + db_calendar_id + '/events/' + db_event_id + '?delete=1&recur=future&date=' + elm.ancestors()[5].id, 'put');
            });
            var cancel = new LertButton('Annuler', function() {

            });

            var exampleLert = new Lert(
              recur_delete_message,
              [cancel, future, only],
              {
                defaultButton: only,
                icon:'/javascripts/lert-1.0/i/dialog-warning.png'
              });

              exampleLert.display();
            } else {
              ajax_link('/calendars/' + db_calendar_id + '/events/' + db_event_id, 'delete');
            };
          }