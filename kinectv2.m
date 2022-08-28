clear; close all;clc
imaqreset;
tracer = 0;
previous_joints = ones(1, 75);
depthVid = videoinput('kinect',2);
iniTime = clock;
limit   = 1 * 60;
triggerconfig (depthVid,'manual');
framesPerTrig = 30;
depthVid.FramesPerTrigger = framesPerTrig;
depthVid.TriggerRepeat = inf;

prop = getselectedsource(depthVid);
prop.EnableBodyTracking = 'on';
%prop.TrackingMode = 'Skeleton';
start(depthVid)

himg = figure;

while ishandle(himg)
    if etime(clock, iniTime) < limit
        %disp("starting")
        trigger(depthVid)
        %disp("starting 222")
        [frameDataDepth, timeDataDepth, metaDataDepth] = getdata(depthVid);
        for t = 1:length(timeDataDepth)
            if  sum(metaDataDepth(t).IsBodyTracked) > 0
                tracer = 1;
                skeletonJoints = metaDataDepth(t).JointPositions(:,:,metaDataDepth(t).IsBodyTracked);
                try
                   delete(h)
                end
                h = plot(skeletonJoints(:,1), skeletonJoints(:,2),'.','MarkerSize',15); % Plota no imshow as juntas
                axis([-2.1 2.1 -2.1 2.1])
            end
        if tracer == 1
            for re = 1:25
                if re == 1
                    prev_segment = skeletonJoints(re, :);
                else
                    segment = skeletonJoints(re,:);
                    concat = [prev_segment, segment];
                    prev_segment = concat;
                    disp(" frame concat ......")
                end
            end
            %reshape_skeletonJoints = reshape(skeletonJoints,[1,75]);
            reshape_skeletonJoints = concat;
            previous_joints = [previous_joints;reshape_skeletonJoints];

            %csvwrite('Test/Train_X.csv',previous_joints);
            tracer = 0;
        end
        end
    else
        csvwrite('Test/Train_X.csv',previous_joints);
        break;
    end
end
disp("Done")