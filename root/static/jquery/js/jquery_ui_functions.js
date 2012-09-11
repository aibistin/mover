$(function(){

        //     bind 'form' and provide a simple callback function 
        //$('#estForm').ajaxForm(function() { 
        //    alert("You are all fired!"); 
        //});
        
            // Accordion
            $("#accordion").accordion({ header: "h3" });

            // Tabs
            $('#nothing').tabs();

            // Dialog			
            $('#dialog').dialog({
                autoOpen: false,
                width: 600,
                buttons: {
                    "OK": function() { 
                        $(this).dialog("close"); 
                    }, 
                    "OK": function() { 
                        $(this).dialog("close"); 
                    } 
                }
            });
            
            // Dialog Link
            $('#dialog_link').click(function(){
                $('#dialog').dialog('open');
                return false;
            });
            
            // Datepicker
            $('#estimate_date').datepicker(
                {
                inline: true,
                dateFormat: "yy-mm-dd"
            });
            
            // Slider
            $('#slider').slider({
                range: true,
                values: [17, 67]
            });
            
            // Progressbar
            $("#progressbar").progressbar({
                value: 20 
            });
            
            //hover states on the static widgets
            $('#dialog_link, ul#icons li').hover(
                function() { $(this).addClass('ui-state-hover'); }, 
                function() { $(this).removeClass('ui-state-hover'); }
            );

           
        });