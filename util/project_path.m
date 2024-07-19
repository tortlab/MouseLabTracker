function path = project_path()

m_filepath = mfilename('fullpath');
[util_path u1 u2] = fileparts(m_filepath);
[path u1 u2] = fileparts(util_path);
end
