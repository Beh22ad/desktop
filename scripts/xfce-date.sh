#!/bin/bash
# jalali.sh – convert current Gregorian date (Asia/Tehran) to Jalali date
# and print specific parts of the date based on the given parameter:
#   d: [Persian Day-of-Week]
#   s: [month/day] in Persian digits
#   y: [year] in Persian digits

# Arrays for Persian day names, month names, and digits
persianDays=(یکشنبه دوشنبه سه‌شنبه چهارشنبه پنجشنبه جمعه شنبه)
persianMonths=("فروردین" "اردیبهشت" "خرداد" "تیر" "مرداد" "شهریور" "مهر" "آبان" "آذر" "دی" "بهمن" "اسفند")
persianNumbers=("۰" "۱" "۲" "۳" "۴" "۵" "۶" "۷" "۸" "۹")

# Function to convert an integer (or string of digits) to Persian numbers
toPersian() {
    local num="$1"
    local result=""
    local i ch
    for (( i=0; i<${#num}; i++ )); do
        ch="${num:$i:1}"
        if [[ "$ch" =~ [0-9] ]]; then
            result+="${persianNumbers[$ch]}"
        else
            result+="$ch"
        fi
    done
    echo "$result"
}

# Get current Gregorian date components in Asia/Tehran timezone
TZ="Asia/Tehran" gregYear=$(date +%Y)
TZ="Asia/Tehran" gregMonth=$(date +%-m)  # remove leading zero
TZ="Asia/Tehran" gregDay=$(date +%-d)

# Define the number of days in each Gregorian month (index 0 = January)
gDaysInMonth=(31 28 31 30 31 30 31 31 30 31 30 31)

# Prepare variables (all arithmetic is integer arithmetic)
gy=$gregYear
gm=$gregMonth
gd=$gregDay

# Calculate gy2: if month > 2 then gy+1, else gy
if [ $gm -gt 2 ]; then
    gy2=$((gy + 1))
else
    gy2=$gy
fi

# Start with base days calculation:
days=$((355666 + 365 * gy + ( (gy2 + 3) / 4 ) - ((gy2 + 99) / 100) + ((gy2 + 399) / 400) + gd))

# Add days for months before the current month
for (( i=0; i<gm-1; i++ )); do
    days=$((days + gDaysInMonth[i]))
done

# Check for leap year and if month > February then add one day
if [ $gm -gt 2 ]; then
    if (( (gy % 4 == 0 && gy % 100 != 0) || (gy % 400 == 0) )); then
        days=$((days + 1))
    fi
fi

# Convert Gregorian days count to Jalali (Persian) date:
# First, calculate the year
jy=$(( -1595 + 33 * (days / 12053) ))
days=$(( days % 12053 ))
jy=$(( jy + 4 * (days / 1461) ))
days=$(( days % 1461 ))
if [ $days -gt 365 ]; then
    jy=$(( jy + (days - 1) / 365 ))
    days=$(( (days - 1) % 365 ))
fi

# Now determine month (jm) and day (jd)
if [ $days -lt 186 ]; then
    jm=$(( 1 + days / 31 ))
    jd=$(( 1 + days % 31 ))
else
    jm=$(( 7 + (days - 186) / 30 ))
    jd=$(( 1 + (days - 186) % 30 ))
fi

# Get day-of-week in Asia/Tehran timezone (0=Sunday, …,6=Saturday)
dow=$(TZ="Asia/Tehran" date +%w)
# Use dow as index directly (our persianDays array: index 0=یکشنبه, …)
persianDay="${persianDays[$dow]}"

# Convert Jalali year, month, day to Persian digits
pjy=$(toPersian "$jy")
pjm=$(toPersian "$jm")
pjd=$(toPersian "$jd")

# Check the argument and output accordingly
case "$1" in
    d)
        echo "$persianDay"
        ;;
    s)
        echo "$pjm/$pjd"
        ;;
    y)
        echo "$pjy"
        ;;
    *)
        echo "Usage: $0 {d|s|y}"
        ;;
esac
