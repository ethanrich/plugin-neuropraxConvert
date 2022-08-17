function [] = loadEEG(filename)
  warning('off', 'all');
##  filename = "C:\\Users\\eri\\OneDrive - neurocare group AG\\Documents\\readEEG_testData\\20211014163742.EEG";

  savepath = ""; % initialize an empty string that will be set from Python later

  % read in all data
  start=0;        % starting with the first
  laenge=inf;     % ending with the last
  typ='samples';  % sample in the data

  % do the conversion from binary files
  NP_data = np_readdata(filename,start,laenge,typ);
  NP_info = np_readfileinfo(filename);
  NP_marker = np_readmarker(filename,0,inf,'samples');
  % save
  save([savepath filename(1:end-4) "_NP_data.mat"], 'NP_data', '-v7')
  save([savepath filename(1:end-4) "_NP_info.mat"], 'NP_info', '-v7')
  save([savepath filename(1:end-4) "_NP_marker.mat"], 'NP_marker', '-v7')
end
