#!/usr/bin/env python3

import csv
import sys
import os
import datetime

def get_source(file_location):
    entries = []

    with open(file_location) as csv_file:
        
        lines = list(csv.reader(csv_file))
        for line in lines[1:]:
            temp = ""
            catagory = ""
            c = line[16]

            if "English" in c or "Literature" in c:
                catagory = "English"
            if "Math" in c:
                catagory = "Math"
            if "Science" in c or "Biology" in c or "Chemistry" in c or "Physics" in c or "Psychology" in c:
                catagory = "Science"
            if "Humanities" in c or "Politics" in c or "Economics" in c or "History" in c or "Criminal" in c:
                catagory = "Humanities"
            if "Tech" in c or "Community" in c or "Workshop" in c or "Computer" in c or "D&T" in c or "Metalwork" in c or "Design" in c  or"Digital" in c or "Media" in c or "Photography" in c or "Robotics" in c or "Woodwork" in c:
                catagory = "Technologies"
            if "Art" in c or "Craft" in c or "Dance" in c or "Drama" in c:
                catagory = "The Arts"
            if "Physical" in c or "Health" in c or "Music" in c or "Outdoor" in c or "Fitness" in c or "Training" in c:
                catagory = "Physical Education"
            if "French" in c or "Indonesian" in c:
                catagory = "Languages"
            if "Career" in c:
                catagory = "Civics"
            if "Certificate" in c:
                catagory = "Vocational Education"
            if "Independent" in c or "Planning" in c:
                catagory = "Private Study"
            if "Shed" in c:
                catagory = "Shed Program"
 
            temp = line[15] + "," + line[16] + "," + line[19] + " " + line[20] + " " + line[21] + "," + catagory + "," + line[17] + "," + line[1] + " " + line[2] + "," + line[0] + "\n"
            entries.append(temp)

    return entries


# Usage:
# transfer_studentgroup.py "/Path/to/CSV"
# this will place a new CSV in the same location as the source file
def append_csv():

    source_location = sys.argv[1]
    target_location = os.path.split(source_location)[0] + "/Bunbury Student Group " + datetime.datetime.now().strftime('%B-%Y') + ".csv"
    
    rows = get_source(source_location)

    with open(target_location, "w") as csv_file:
        csv_file.write("Group Name,Group Description,Group Staff,Group Catagory,Class Year,Studnet Name,Student ID\n")
        for student in rows:
            csv_file.write(student)


append_csv()
