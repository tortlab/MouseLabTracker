function handle = guiobj(name)

handles = loadhandles();
handle = handles.(name);
end
