$(document).ready ->
  $.attachinary.config.template = """
    <ul>
      <% for(var i=0; i<files.length; i++){ %>
        <li>
          <% if(files[i].resource_type == "raw") { %>
            <div class="raw-file"></div>
          <% } else { %>
            <img
              src="<%= $.cloudinary.url(files[i].public_id, { "version": files[i].version, "format": "jpg", "crop": "fill", "width": 250, "height": 250 }) %>"
              alt="" width="100" height="100" />
          <% } %>
          <i class="remove fa fa-times" aria-hidden="true" data-remove="<%= files[i].public_id %>"></i>
        </li>
      <% } %>
    </ul>
  """


  $('.attachinary-input').attachinary({})
