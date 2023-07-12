function det_res = getLosspos_sin2_Diran(det)
    det_res = det;
    [det_num,angle_num,coef_num] = size(det);
    det_index = 1:det_num;
    
    for j = 1:angle_num
        for k = 1:coef_num
                %1 计算丢失探测器的数量和索引
                loss_num = 0;
                for i = 1:det_num
                    if(abs(det(i,j,k))<1e-5)
                        loss_num = loss_num + 1;
                    end
                end
                loss_index = zeros(loss_num,1);
                loss_num = 0;
                for i = 1:det_num
                    if(abs(det(i,j,k))<1e-5)
                        loss_num = loss_num + 1;
                        loss_index(loss_num) = i;
                    end
                end

                %2 根据索引将丢失的探测器去掉
                det_get = det(:,j,k);
                det_get(loss_index) = [];
                det_getindex = det_index;
                det_getindex(loss_index) = [];
                
                % 3次样条插值
                fitresult = fit(det_getindex',det_get, 'sin2');
                det_res(loss_index,j,k) = fitresult(loss_index');

        end
    end
end

%                 figure,plot(det_index,det_res(:,j,k),'o');
%                 hold on
%                 plot(det_getindex,det_get,'*')