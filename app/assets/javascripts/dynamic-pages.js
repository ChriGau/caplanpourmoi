$(document).ready(function() {

// page sol list collapse en show panel bootstrap
  var heads = Array.from(document.getElementsByClassName("sol-head"));
  heads.forEach(function(head) {
    head.addEventListener('click', function(){
      var id = this.dataset.id;
      $('#'+ id).collapse("toggle");
    });
  });

})
