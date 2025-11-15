#!/bin/sh

COUNT=$(cat /tmp/hypr_num)
NEXT=pypr change_workspace +"$COUNT"
PREV=pypr change_workspace -"$COUNT"
echo "$COUNT"
