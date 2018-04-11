function net = LoadNet(modelName , epoch ,  usegpu)
    addpath('/home/neilfvhv/Softwares/matconvnet-1.0-beta25/matlab');
	addpath('/data8T/minmm/matconvnet-1.0-beta25/matlab');
	vl_setupnn();
	load(fullfile('../model', [modelName, '-epoch-', num2str(epoch), '.mat']));
	net = vl_simplenn_tidy(net); 
	net.layers = net.layers(1:end - 1);
	net = vl_simplenn_tidy(net); 
	if usegpu == 1
		net = vl_simplenn_move(net, 'gpu');
	end
end
