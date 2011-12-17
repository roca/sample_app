class MobilePaginationListLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
  
  # I created this one to work with a mobile device

  protected
  
     def page_number(page)
       
        
       unless page == current_page
         if @options[:params] && @options[:params][:url]
           link(page, @options[:params][:url] + "?page=" + page.to_s, :rel=>"external")
         else
            link(page,  page, :rel => rel_value(page))
         end
       else
         tag(:span, page, :class => "current")
       end
     end
  
     def previous_or_next_page(page, text, classname)
       if page
         if @options[:params] && @options[:params][:url]
           tag(:span, link(text, @options[:params][:url] + "?page=" + page.to_s, :class => classname, :rel=>"external"))
         else
           tag(:span, link(text,  page, :rel => rel_value(page), :class => classname))
         end
       else
         tag(:span, text, :class => classname + ' disabled')
       end
     end
  
     def html_container(html)
       tag(:div, html, container_attributes)
     end

end