$(function() {
  //$('.menu-trigger').on('click', function(event) {
  $(document).on('click','.menu-trigger',function(event){

    $(this).toggleClass('active');
    $('#sp-menu').fadeToggle();
    //event.preventDefault();
    return false;
  });
});