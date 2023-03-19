local prev_para = nil

function contains_strong_element(elem)
    if elem.t == "Strong" then
        return true
    end

    if elem.content then
        for _, child in ipairs(elem.content) do
            if contains_strong_element(child) then
                return true
            end
        end
    end

    return false
end

function Para(el)
    local attr = pandoc.Attr("", {}, {class="lead"})
    local is_lead = false
    local content = pandoc.utils.stringify(el)
    if string.match(content, "^Example[: ]") then
        is_lead = true
    elseif prev_para ~= nil and string.sub(pandoc.utils.stringify(prev_para), -1) == ":" then
    elseif not string.match(content, "^[-a-zA-Z0-9 ]+:") then
        -- check bold 
        is_lead = true
    else
        is_lead = not contains_strong_element(el)
    end
    prev_para = el
    if is_lead then
        return pandoc.Div(el.content, attr)
    end
end

function Header(el)
    if el.level == 6 then
        local header_text = pandoc.utils.stringify(el.content)
        local colon_pos = string.find(header_text, ":", 1, true)
        local attr = pandoc.Attr("", {}, {class="head"})
        if colon_pos then
            local text_before_colon = string.sub(header_text, 1, colon_pos-1)
            local text_after_colon = string.sub(header_text, colon_pos+1)
            local bold_text = pandoc.Strong(text_before_colon)
            local line_break = pandoc.LineBreak()
            local new_header_text = pandoc.List{ line_break, bold_text, pandoc.Str(": "..text_after_colon) }
            return pandoc.Div(new_header_text, attr)
        end
    end
end
