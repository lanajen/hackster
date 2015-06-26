// prevents submission of form if provided default value is still present in target input
// form = form id to submit
// default_val = value set in function call
// input_id = input id to check default value of input
// cdg 7/5/2011
// example call: preventSubmit("#searchbox_protect", "Search catalog", "#SearchForm_SearchForm_Search");
function preventSubmitIf(form, default_val, input_id) {
  $(form).submit(function(){
    if($(input_id).val() === default_val){
	  if(!$(form + " .msgAlert").length){	
	      $(form).append("<div class='msgAlert'>Enter a search value.</div>");
	  }
	  return false;
    }else{
      return true;
    }
  });
}




//Clears input fields with class text and textareas on click
// form = form id 
// example call: clearField("#someform")
function clearField(form) {
        jQuery(form).find("input.text, textarea").each(function(){ 
            this.defaultValue = this.value;
            jQuery(this).click(function(){
                if(this.value == this.defaultValue){
                    jQuery(this).val("");
                }
                return false;
            });
            jQuery(this).blur(function(){
                if(this.value == ""){
                    jQuery(this).val(this.defaultValue);
                }
            });
        });
}


var QueryString = function () {
  // This function is anonymous, is executed immediately and 
  // the return value is assigned to QueryString!
  var query_string = {};
  var query = window.location.search.substring(1);
  var vars = query.split("&");
  for (var i=0;i<vars.length;i++) {
    var pair = vars[i].split("=");
    	// If first entry with this name
    if (typeof query_string[pair[0]] === "undefined") {
      query_string[pair[0]] = pair[1];
    	// If second entry with this name
    } else if (typeof query_string[pair[0]] === "string") {
      var arr = [ query_string[pair[0]], pair[1] ];
      query_string[pair[0]] = arr;
    	// If third or later entry with this name
    } else {
      query_string[pair[0]].push(pair[1]);
    }
  } 
    return query_string;
} ();



if (typeof console === "undefined"){
    console={};
    console.log = function(){
        return;
    }
}



