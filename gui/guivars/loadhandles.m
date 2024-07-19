function handles = loadhandles()

    global handles__;

    if isempty(handles__)
        handles = guihandles();
    else
        handles = handles__;
    end
end
