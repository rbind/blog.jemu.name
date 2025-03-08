// Initialize littlefoot.js
littlefoot.default({
    activateOnHover: false,
    dismissDelay: 50,
    // buttonTemplate: '<button aria-label="Footnote <% number %>" class="littlefoot__button" id="<% reference %>" title="See Footnote <% number %>" /> <% number %> </button>'
    buttonTemplate: '<button class="littlefoot__button" id="<% reference %>" title="See Footnote <% number %>" data-footnote-id="<% number %>"><% number %></button>'
})
