function [iipos,ypos,iineg,yneg]=findpeaks_martin(t,y)


                % *** Peak picking code ***
        %Find crossing points
        y_positive = find(y>mean(y));
        diff_y_positive = y_positive(2:end) - y_positive(1:end-1);
        jump_points = find(diff_y_positive > 1);
        crossing_to_negative = y_positive(jump_points);
        crossing_to_positive = y_positive(jump_points+1);

        %Between each crossing point pair, find the peaks/troughs
        %Always starts with trough negative
        %Check whether ends with peak or trough
        if length(crossing_to_negative) > length(crossing_to_positive)
            end_offset = 0;
        else
            end_offset = 1;
        end
        clear y_peak pos_peak y_trough pos_trough %Clear data from last wave
        %Find maximum of peak
        for k=1:length(crossing_to_positive) - end_offset
            [y_peak(k), index] =     max(y(crossing_to_positive(k):crossing_to_negative(k+1)));
            pos_peak(k) = crossing_to_positive(k) + index - 1;
        end
        t_peak = t(pos_peak);
        %Find minimum of trough
        for k=1:length(crossing_to_positive)
            [y_trough(k), index] = min(y(crossing_to_negative(k):crossing_to_positive(k)));
            pos_trough(k) = crossing_to_negative(k) + index - 1;

        end
        t_trough = t(pos_trough);

        %Find ABSOLUTE magnitudes of all peaks/troughs in one array
        y_mag = abs([y_peak, y_trough]);
        % *** End of peak picking code ***
        
        iipos=pos_peak;
        y_pos=y_peak;
        iineg=pos_trough;
        y_neg=y_trough;
        