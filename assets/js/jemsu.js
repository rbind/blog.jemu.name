// Initialize littlefoot.js
littlefoot.default({
    activateOnHover: false,
    dismissDelay: 50,
    buttonTemplate: '<button aria-label="Footnote <% number %>" class="littlefoot__button" id="<% reference %>" title="See Footnote <% number %>" /> <% number %> </button>'
})


// Scroll to top thing: https://www.w3schools.com/howto/howto_js_scroll_to_top.asp

//Get the button:
scrollbutton = document.getElementById("totop");

if (typeof (scrollbutton) != 'undefined' && scrollbutton != null) {

    // When the user scrolls down 1000px from the top of the document, show the button
    window.onscroll = function () { scrollFunction() };

    function scrollFunction() {
        if (document.body.scrollTop > 1000 || document.documentElement.scrollTop > 1000) {
            scrollbutton.style.visibility = "visible";
            scrollbutton.style.opacity = "1";
        } else {
            scrollbutton.style.visibility = "hidden";
            scrollbutton.style.opacity = "0";

        }
    }

    // When the user clicks on the button, scroll to the top of the document
    function topFunction() {
        document.body.scrollTop = 0; // For Safari
        document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
    }

}
