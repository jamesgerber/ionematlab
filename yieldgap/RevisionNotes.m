function txt=revisionnotes(Rev)

switch Rev
    case 'N'
        txt='no soils.  select contour by gaussian smoothing.'
    case 'M'
        txt='with soils.  select contour by monotonic non-smoothed method (now replaced by rev L).'
    case 'H'
        txt='no soils.  select contour by monotonic non-smoothed method (now replaced by rev L).'

    case 'K'
        txt='no soils.  reject 95% via area filter, then inclusive bins.'
    case 'L'
        txt='with soils.  reject 95% via area filter, then inclusive bins.'
    case 'O'
        txt='no soils.  select contour by gaussian smoothing.''

    otherwise
        txt='haven''t programmed in'
end

        