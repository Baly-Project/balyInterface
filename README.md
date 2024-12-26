# balyInterface
 A digital gallery built around the Denis Baly Slide Collection.

## Overview
The rails app is contained in the interface/ folder, in which the app/ folder contains all the code that may need occaisonal maintance.

To import the app onto a new server, follow the setup instructions in [this configuration file](configuration.md)

For a detailed explanation of the code and directions for further development, check out the [interface README](/interface/README.md).

## Contents
The repository has three folders.

- The interface folder contains the source code for the Rails app
- The methodTesting folder contains a copy of the interface models, and can be used for testing and update simulation
- The samplePages folder contains HTML prototypes of various views

## Development Notes
Some of the most important workflows used in developing and updating the rails app

### General Workflow
Rules to follow when updating and developing.

1. #### Protect the production server
    - All changes should be made on a separate server, configured using the steps in [configuration.md](configuration.md).
    - All changes should be made in a new github branch, **not main**.
    - Thoroughly test all large modifications, and always complete features before merging with the main branch.
    - Merges can be made with pull requests on the github webpage for the project. If there is more than one person working on the project, pull requests (to main) **must** be approved by one other member of the [Baly Project Organization](https://github.com/Baly-Project). An organization administrator has the ability to override this safeguard, but this should only ever be used in one-developer situations.
    - When changes are ready to be put in production and have been incorporated into the main branch, **strictly** adhere to the following steps:
    1. Type `git pull` to pull the changes.
    2. Execute any commands performed during new development
    3. Execute these standard rails commands to ensure full sync with updated version
       ```sh  
       bundle install
       rails assets:clobber
       rails assets:precompile
       rake record:update
       ```
    4. Execute the following commands **together** to end the running server and restart it with the new changes. This will put the server down for a moment, and if you are running on a multi-processor system then you should explore options for zero-downtime deploys such as [this tutorial from Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-set-up-zero-downtime-rails-deploys-using-puma-and-foreman). 

       ```sh
       pkill -9 ruby
       nohup rails s -e production -b 0.0.0.0 &
       ```
    5. Check that the server is running at [baly.kenyon.edu](https://baly.kenyon.edu), and test the new feature immediately. If anything does not work as expected, revert your changes by typing `git log` and picking the last commit before the merge, then typing `git checkout COMMIT HASH` where COMMIT HASH is the first 7 characters in the string of numbers and letters at the top of that commit's log entry. This will revert to the version before the merge, and repeating step iv (previous) should start the server back the way it was. When the changes have been fixed, follow this entire list from the top.

2. #### Preserve Documentation State
   Before a change is added by a commit, make sure to update the documentation and testing as much as possible to reflect the changes. This helps prevent obsolete information from entering the main branch and ensures that commits can be reverted cleanly.

