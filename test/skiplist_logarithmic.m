# Load files from test/benchmark_results/ directory
#
# Legend names will be fail names without extension
#
files = glob('benchmark_results/*.txt')
for i=1:numel(files)
  file_name = strsplit(strsplit(files{i}, '/'){end}, '.'){1}
  skiplist.(file_name) = load(files{i})
endfor

markers = ['+', 'o', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'];
i = 0;
hold on
for [val, key] = skiplist
  marker = markers(mod(i, columns(markers)) + 1)
  display_name = strrep(key, '_', '\_')
  color = 'green'

  if (strncmp(display_name, 'fail', 4))
    color = 'red'
  endif

  loglog(
    [1: columns(val)], val,
    'DisplayName', display_name,
    'linewidth', 1.5,
    'marker', marker,
    'color', color
  );

  i += 1;
endfor
set(legend('show'), 'fontsize', 17);
set(title('Skiplist times for 4000 insert operations'), 'fontsize', 17);
grid('minor');
waitfor(gcf);
