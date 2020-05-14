// Initialize littlefoot.js
littlefoot.default({
  activateOnHover: false,
  dismissDelay: 50,
  buttonTemplate: "<button aria-controls='fncontent:<% id %>' aria-expanded='false' aria-label='Footnote <% number %>' class='littlefoot-footnote__button' id='<% reference %>' rel='footnote' title='See Footnote <% number %>' /><% number %></button>"
})

// Color theme toggler via zookee1 <3
function toggleDarkMode() {
  let bodyClassList = document.body.classList;
  let userPreferredIsLight = (window.matchMedia('(prefers-color-scheme: light)').matches)
  
  if(!bodyClassList.contains('colorscheme-dark') && 
     !bodyClassList.contains('colorscheme-light')) {
      bodyClassList.remove("colorscheme-auto");
      if(userPreferredIsLight) {
          bodyClassList.add("colorscheme-dark");            
      } else {
          bodyClassList.add("colorscheme-light");            
      }
  } else {
      if(bodyClassList.contains('colorscheme-dark')) {
          bodyClassList.add("colorscheme-light");
          bodyClassList.remove("colorscheme-dark");
      } else if(bodyClassList.contains('colorscheme-light')) {
          bodyClassList.add("colorscheme-dark");
          bodyClassList.remove("colorscheme-light");
      }
  }
}
