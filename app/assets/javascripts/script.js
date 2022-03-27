$(function() {
  $(document).on('click','.menu-trigger',function(event){

    $(this).toggleClass('active');
    $('#sp-menu').fadeToggle();

    return false;
  });
});