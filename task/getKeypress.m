
%% get keypress for this subject
%female(=1)/male(=2)
%indoor(=1)/outdoor(=2)
%natural(=1)/manmade(=2)
%reward(=1)/neutral(=2)

load([out_mat_dir '/keypressRandomization']);

faces = {'female' 'male'};
scenes = {'indoor' 'outdoor'};
objects = {'natural' 'manmade'};
reward = {'reward' 'neutral'};

keypress.female = keypressRandomization{this_subj}(1,1);
keypress.male = keypressRandomization{this_subj}(1,2);
keypress.indoor = keypressRandomization{this_subj}(2,1);
keypress.outdoor = keypressRandomization{this_subj}(2,2);
keypress.natural = keypressRandomization{this_subj}(3,1);
keypress.manmade = keypressRandomization{this_subj}(3,2);
keypress.reward = keypressRandomization{this_subj}(4,1);
keypress.neutral = keypressRandomization{this_subj}(4,2);

left_face = char(faces(find(keypressRandomization{this_subj}(1,:) == 1)));
left_scene = char(scenes(find(keypressRandomization{this_subj}(2,:) == 1)));
left_object = char(objects(find(keypressRandomization{this_subj}(3,:) == 1)));
left_reward = char(reward(find(keypressRandomization{this_subj}(4,:) == 1)));

right_face = char(faces(find(keypressRandomization{this_subj}(1,:) == 2)));
right_scene = char(scenes(find(keypressRandomization{this_subj}(2,:) == 2)));
right_object = char(objects(find(keypressRandomization{this_subj}(3,:) == 2)));
right_reward = char(reward(find(keypressRandomization{this_subj}(4,:) == 2)));

clear faces scenes objects reward