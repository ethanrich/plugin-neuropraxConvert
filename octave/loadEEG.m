function [] = loadEEG(filename)
##  filename = "20211014163742.EEG";

  savepath = "";
  ##% [NP_data, NP_info, NP_marker] = readNEUROPRAX(filename);

  % read in all data
  start=0;        % starting with the first
  laenge=inf;     % ending with the last
  typ='samples';  % sample in the data

  ##  NP_data = np_readdata(filename,start,laenge,typ);
  NP_info = np_readfileinfo(filename);
  ##NP_marker = np_readmarker(filename,0,inf,'samples');

  ##save('NP_data.mat', 'NP_data')
  save([savepath filename(1:end-4) "_NP_info.mat"], 'NP_info', '-v7')
  ##save('NP_marker.mat', 'NP_marker')
end
