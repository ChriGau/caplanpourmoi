$(document).ready(function() {
  var options = {
    horizontal: 1,
    itemNav: 'basic',
    speed: 300,
    mouseDragging: 1,
    touchDragging: 1,
    forward: $('.forward'),
    backward: $('.backward'),
    clickBar: true,
    moveBy: 1300,
    scrollBar: $('.scrollbar'),
    dragHandle: true,
    clickBar: true,
    // dynamicHandle: true,


  };
  $('#planning-list').sly(options);
});
