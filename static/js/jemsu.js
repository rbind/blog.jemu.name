// Initialize littlefoot.js
littlefoot.default({
  activateOnHover: false,
  dismissDelay: 50,
  buttonTemplate: "<button aria-controls='fncontent:<% id %>' aria-expanded='false' aria-label='Footnote <% number %>' class='littlefoot-footnote__button' id='<% reference %>' rel='footnote' title='See Footnote <% number %>' /><% number %></button>"
})
