function [scores,average,weighted_avg,fhs] = ...
    gofScores(measurement,simulation,fmin,fmax,...
    plot_options,baseline_options,filter_order,exact_resp_spect)
% USAGE: [scores,average,weighted_avg,fhs] = ...
%     gofScores(measurement,simulation,fmin,fmax,...
%     plot_options,baseline_options,filter_order,exact_resp_spect)
%
% Calculate goodness-of-fit scores, as defined in Shi & Asimaki (2017).
%
% [INPUTS]
%    measurement: Measured time series (in two columns: time in sec,
%                 acceleration)
%    simulation: Simulated time series (in two columns, time and accel.)
%    fmin: Minimum frequency to be considered (Hz)
%    fmax: Maximum frequency to be considered (Hz)
%    plot_option: Whether or not to plot comparison figures for measurement
%                 and simulation. A 4-element vector, whose each element is
%                 either 0 or 1, which corresponds to whether: (1) scores
%                 1-4, (2) scores 5-7, (3) scores 8-9, and (4) final
%                 summary, will be displayed respectively. Default is [0,
%                 0, 0, 0]
%    baseline_options: Whether or not to perform baseline correction for
%                      scores 5-7 and scores 8-9. This should be a 
%                      two-element vector. Default is [1, 1].
%                      Please do not change this default unless you really
%                      know what you are doing.
%    filter_order: The order of band pass filter to be performed to both
%                  measurement and simulation. Default is 4. Please do not
%                  change this default unless you really know what you are
%                  doing.
%    exact_resp_spect: Whether or not to use exact response spectra
%                      calculator (slower) as opposed to approximate
%                      response spectra calculator (faster). Default: 'y'.
%
% [OUTPUTS]
%    scores: A row vector whose 1st to 9th element are the 9 scores
%    average: The plain average score of the 9 scores
%    weighted_avg: Weighted average of the 9 scores, which combines S1 and
%                  S2, S3 and S4 (respectively).
%    fhs: figure handles of the four possible figures, i.e., [fh1234,fh567,fh89,fhstft]
%
% (c) Jian Shi, 7/21/2013
%
%
% [UPDATE LOG]
%
%   In February 2015: A new scoring scheme (from -10 to 10) is used, which
%                     eventually goes into Shi & Asimaki (2017).
%
%   On 12/29/2015, "exact_resp_spect" option is added.

if nargin < 8, exact_resp_spect = 'y'; end
if nargin < 7, filter_order = 4; end
if nargin < 6, baseline_options = [1 1]; end
if nargin < 5, plot_options = [0 0 0 0]; end

if size(measurement,2) ~= size(simulation,2)
    error('Length of ''measurement'' and ''simulation'' must be the same.');
end

t = measurement(:,1);
n = length(t);
dt = t(2)-t(1);
fs = 1/dt;  % sampling frequency

if (nargin < 4) || isempty(fmax)
    fmax = fs/2;
end
if (nargin < 3) || isempty(fmin)
    fmin = fs/n;
end

if (nargin >= 4) && (fmin >= fmax)
    error('***** fmax must be larger than fmin. *****');
end

[c1,c2,c3,c4,fh1234] = d_1234(measurement,simulation,fmin,fmax,plot_options(1),filter_order);
[c5,c6,c7,fh567] = d_567(measurement,simulation,fmin,fmax,plot_options(2),baseline_options(1),filter_order);
[c8,c9,fh89] = d_89(measurement,simulation,fmin,fmax,plot_options(3),baseline_options(2),exact_resp_spect);

scores = [c1,c2,c3,c4,c5,c6,c7,c8,c9];
average = (c1+c2+c3+c4+c5+c6+c7+c8+c9)/9;
weighted_avg = ((c1+c2)/2+(c3+c4)/2+c5+c6+c7+c8+c9)/7;
fhs = [fh1234,fh567,fh89];

if plot_options(4) == 1
    fh = figure('visible','on','name','Overall');
    width = 12; height = 4;
    xLeft = (16-width)/2;  yBottom = (10-height)/2;
    set(fh,'units','inches','position',[xLeft, yBottom, width, height]);
    plot(1:1:9,[c1,c2,c3,c4,c5,c6,c7,c8,c9],'bo','linewidth',2); hold on;
    plot([1,9],[average,average],'r--','linewidth',2);
    ylim([-10 10]);
    set(gca,'yTick',-10:1:10);
    set(gca,'xTickLabel',{'Ia-duration','Ie-duration','Ia-peak','Ie-peak','PGA','PGV','PGD','Resp. Spect.','Fourier Spect.','STFT'},...
        'fontname','Times New Roman','fontsize',14);
    grid on;
    legend('Individual score','Average score','location','best');
end

end
