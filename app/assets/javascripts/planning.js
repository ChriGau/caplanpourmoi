$(document).ready(function() {
  var options = {
    horizontal: 1,
    itemNav: 'centered',
    speed: 300,
    mouseDragging: 1,
    touchDragging: 1,
    forward: $('.forward'),
    backward: $('.backward'),
    clickBar: true,
    moveBy: 1000,
    scrollBar: $('.scrollbar'),
    dragHandle: true,
    clickBar: true,
    // dynamicHandle: true,

  };
  if ($("#planning-list")[0]) {
  var sly = new Sly('#planning-list', options).init();
  sly.toCenter(true);
  }
});
