#!/bin/bash

set -e

# Define Teams
area=( "test" "user" "needs" "to" "be" "added" "here"
ninja=( "mling" "nsagoo" "jguthrie" )
all_no_ninja=( "${area[@]}" )
all=( "${all_no_ninja[@]}" "${ninja[@]}" )
generalORG=GeneralORG

# Functions for script
create_user ()
{
	echo 'creating user -' $1
	create_ninja $1
	create_user_org $1-org $1
	create_spaces $1-org
	manage_space_manager $1 $1-org development
	manage_space_manager $1 $1-org staging
	manage_space_manager $1 $1-org production
}

create_ninja ()
{
	echo 'creating user -' $1
  n=0
  until [ $n -ge 5 ]
  do
    cf create-user $1 password && break
    n=$[$n+1]
    echo 'sleeping for 15 secs and try again'
    sleep 15
  done
}

create_user_org ()
{
	echo 'creating org -' $1 ' for - ' $2
	cf create-org $1
	cf set-org-role $2 $1 OrgManager

	#Ninjas should have access
	for i in "${ninja[@]}"
	do
    cf set-org-role $i $1 OrgManager
	done
}

create_spaces ()
{
	echo 'creating spaces for org -' $1
	cf create-space development -o $1
	cf create-space staging -o $1
	cf create-space production -o $1

	#Ninjas should have access and be managers
	for i in "${ninja[@]}"
	do
		U=$i
		cf set-org-role $U $1 OrgManager
		manage_space_manager $U $1 development
		manage_space_manager $U $1 staging
		manage_space_manager $U $1 production
	done
}

manage_space()
{
	ROLES=("SpaceDeveloper" "SpaceAuditor")
	for i in "${ROLES[@]}"
	do
		echo 'setting space role - ' $1 $2 $3 $i
		cf set-space-role $1 $2 $3 $i
	done
}

manage_space_manager()
{
	ROLES=("SpaceManager" "SpaceDeveloper" "SpaceAuditor")
	for i in "${ROLES[@]}"
	do
		echo 'setting space role - ' $1 $2 $3 $i
		cf set-space-role $1 $2 $3 $i
	done
}

# Create the teenage mutant ninja turtle force
for i in "${ninja[@]}"
do
  echo "creating ninja force"
  create_ninja $i
done

for i in "${all[@]}"
do
  create_user $i
done

# Create general group org everyone is part of

cf create-org $generalORG
create_spaces $generalORG

for i in "${all_no_ninja[@]}"
do
	U=$i
	cf set-org-role $U $ORG OrgAuditor
	manage_space $U $ORG development
	manage_space $U $ORG staging
	manage_space $U $ORG production
done

# Create area orgs for teams
