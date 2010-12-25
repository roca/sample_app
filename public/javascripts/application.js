// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// 
// jQuery.ajaxSetup({ 
//   'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
// })

jQuery.fn.submitWithAjax = function() {
  this.submit(function() {
	$.post(this.action, $(this).serialize(), null, "script");
    return false;
  })
  return this;
};

$(document).ready(function() {
  $("#follow_form").live('click',

   function() { 
      $("form:visible[id*='relationship']").submitWithAjax(); 
	}

  );


 $("#search_form").keyup(function() {
    $.get($("#search_form").attr("action"), $("#search_form").serialize(), null, "script");
    return false;
  });


})

